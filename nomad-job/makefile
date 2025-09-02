validate:
	for file in ${TARGET}/*.nomad; do \
		nomad validate $$file; \
	done
deploy:
	for file in ${TARGET}/*.nomad; do \
		nomad run -detach $$file; \
	done

plan:
	for file in ${TARGET}/*.nomad; do \
		nomad plan $$file; \
	done

validate-all:
	make validate TARGET=system
	make validate TARGET=platform
	make validate TARGET=apps
	make validate TARGET=batch
plan-all:
	make plan TARGET=system
	make plan TARGET=platform
	make plan TARGET=apps
	make plan TARGET=batch

deploy-all:
	make deploy TARGET=system
	make deploy TARGET=platform
	make deploy TARGET=apps
	make deploy TARGET=batch
