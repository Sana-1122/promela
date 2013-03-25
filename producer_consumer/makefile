MODEL := producer_consumer

CC := gcc

all: run_simulation


run_simulation:
	spin $(MODEL).pml

run_verifier: generate_verifier
	./pan.elf

generate_verifier:
	spin -a $(MODEL).pml
	$(CC) -o pan.elf pan.c
