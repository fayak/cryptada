CC     := gcc
MACROS := 
SANITIZE := -fsanitize=address
#VALGRIND := valgrind
CFLAGS := -I. -Wundef -Wall -Wextra -O3
CFLAGS_TEST := -I. -Wundef -Wall -Wextra -g $(SANITIZE)

all:
	@$(CC) $(CFLAGS_TEST) bn.c ./tests/bn_convertion.c  -o ./test_bn
	@#$(CC) $(CFLAGS) bn.c ./tests/golden.c      -o ./test_golden
	@#$(CC) $(CFLAGS) bn.c ./tests/hand_picked.c -o ./test_hand_picked
	@#$(CC) $(CFLAGS) bn.c ./tests/load_cmp.c    -o ./test_load_cmp
	@#$(CC) $(CFLAGS) bn.c ./tests/factorial.c   -o ./test_factorial
	@#$(CC) $(CFLAGS) bn.c ./tests/randomized.c  -o ./test_random
	@#$(CC) $(CFLAGS) bn.c ./tests/rsa.c         -o ./test_rsa

bindings: bn.h
	gcc -c -fdump-ada-spec -C bn.h

test: all
	@echo
	@echo REAL TESTS boii
	@$(VALGRIND) ./test_bn

old-test:
	@echo
	@echo ================================================================================
	@./test_golden
	@echo ================================================================================
	@./test_hand_picked
	@echo ================================================================================
	@./test_load_cmp
	@echo ================================================================================
	@python ./scripts/fact100.py
	@./test_factorial
	@echo ================================================================================
	@python ./scripts/test_old_errors.py
	@echo ================================================================================
	@#./test_rsa
	@#echo ================================================================================
	@python ./scripts/test_rand.py 1000
	@echo ================================================================================
	@echo

clean:
	@rm -f ./test_*


