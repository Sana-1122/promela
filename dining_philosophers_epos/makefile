MODEL := dining_philosophers

CC := gcc

all: run_simulation


run_simulation:
	spin $(MODEL).pml

run_verifier: generate_verifier
	./pan.elf

run_verifier_with_cycle_detection_check: generate_verifier
	./pan.elf -a

generate_verifier:
	spin -a $(MODEL).pml
	$(CC) -o pan.elf pan.c

clean:
	rm -f pan.elf pan.b pan.c pan.h pan.m pan.p pan.t $(MODEL).pml.trail *~ *.o
