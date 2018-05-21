PREFIX=${HOME}
install-cli-tools:
	@mkdir -p $(PREFIX)/bin
	@for file in $(wildcard ./bin/*); do\
		printf "Copying "; \
		cp -vf $$file $(PREFIX)/bin/;\
	done
	@if echo $$PATH | grep -qv "$(PREFIX)/bin" ; then\
		echo "Make sure you add "$(PREFIX)/bin" to your PATH variable"; \
	fi

#add the export PATH=~/bin:$PATH to your ~/.bash_profile
