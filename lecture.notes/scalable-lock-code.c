#define CACHELINE 64
struct lock {
  // t-s and t-s-exp
  volatile unsigned int locked;

  // ticket
  volatile unsigned int next_ticket;
  volatile int now_serving;

  // anderson
  volatile struct {
    volatile int x;
    char cache_line[CACHELINE];
  } has_lock[100];
  volatile unsigned int queueLast;
  unsigned int holderPlace;
};

static inline unsigned int
TestAndSet(volatile unsigned int *addr)
{
  unsigned int result;
  unsigned int new = 1;
  
  // x86 atomic exchange.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
               "1" (new) :
               "cc");
  return result;
}


/*
 * Test-and-Set
 */
void
t_s_acquire(struct lock *lock)
{
  while(TestAndSet(&lock->locked) == 1)
    ;
}

void
t_s_release(struct lock *lock)
{
  lock->locked = 0;
}

/*
 * Test-and-Set with exponential delay
 * Simplified -- no randomness.
 */
void
t_s_exp_acquire(struct lock *lock)
{
  int delay = 1;
  int i, junk = 0;
  volatile int junkjunk;

  while(TestAndSet(&lock->locked) == 1){
    // delay
    int howlong = xrandom(delay);
    for(i = 0; i < howlong; i++)
      junk = junk * 3 + 1;
    // double the delay
    if(delay < 1000000)
      delay *= 2;
  }

  junkjunk = junk;
}

/*
 * Atomically increment *p and return
 * the previous value.
 */
static __inline unsigned int
ReadAndIncrement(volatile unsigned int *p)
{ 
    int v = 1;
    __asm __volatile (
    "   lock; xaddl   %0, %1 ;    "
    : "+r" (v),
      "=m" (*p)
    : "m" (*p));
 
    return (v);
}


/*
 * Ticket Lock 
 */
void
ticket_acquire(struct lock *lock)
{
  int me = ReadAndIncrement(&lock->next_ticket);
  while(lock->now_serving != me)
    ;
}

void
ticket_release(struct lock *lock)
{
  lock->now_serving += 1;
}

/*
 * Anderson lock
 */
void
anderson_acquire(struct lock *lock)
{
  int myPlace = ReadAndIncrement(&lock->queueLast);
  while(lock->has_lock[myPlace % numprocs].x == 0)
    ;
  lock->has_lock[myPlace % numprocs].x = 0;
  lock->holderPlace = myPlace;
}

void
anderson_release(struct lock *lock)
{
  int nxt = (lock->holderPlace + 1) % numprocs;
  lock->has_lock[nxt].x = 1;
}






/*
 * MCS locks
 */

struct qnode {
    volatile void *next;
    volatile char locked;
    char __pad[0] __attribute__((aligned(CACHELINE)));
};

typedef struct {
    struct qnode *v  __attribute__((aligned(64)));
    int lock_idx  __attribute__((aligned(64)));
} mcslock_t;

static inline long xchg(long *ptr, long val)
{
        __asm__ volatile(
                "lock; xchgq %0, %1\n\t"
                : "+m" (*ptr), "+r" (val)
                :
                : "memory", "cc");
        return val;
}

static inline long cmpxchg(long *ptr, long old, long val)
{
    uint64_t out;
    __asm__ volatile(
                "lock; cmpxchgq %2, %1"
                : "=a" (out), "+m" (*ptr)
                : "q" (val), "0"(old)
                : "memory");

    return out;
}

static inline void
mcs_init(mcslock_t *l)
{
        l->v = NULL;
}

static inline void
mcs_lock(mcslock_t *l, volatile struct qnode *mynode)
{
        struct qnode *predecessor;

        mynode->next = NULL;
        predecessor = (struct qnode *)xchg((long *)&l->v, (long)mynode);

        if (predecessor) {
                mynode->locked = 1;
		asm volatile("":::"memory")
                predecessor->next = mynode;
                while (mynode->locked)
                        nop_pause();
        }
}

static inline void
mcs_unlock(mcslock_t *l, volatile struct qnode *mynode)
{
        if (!mynode->next) {
                if (cmpxchg((long *)&l->v, (long)mynode, 0) == (long)mynode)
                        return;
                while (!mynode->next)
                        nop_pause();
        }
        ((struct qnode *)mynode->next)->locked = 0;
}
