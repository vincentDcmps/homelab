deploy-all:
	for file in *.nomad; do \
		nomad run -detach $$file; \
	done
plan-all:
	for file in *.nomad; do \
		nomad plan $$file; \
	done
