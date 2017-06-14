NAME=g
VERSION=0.01.02

DIRS=.
PREFIX?=/usr/local
INSTALL_DIR=$(PREFIX)/$(NAME)
INSTALL_DIRS=`find $(DIRS) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) -type f 2>/dev/null`
# DOC_FILES=*.md

# PKG_DIR=pkg
# PKG_NAME=$(NAME)-$(VERSION)
# PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
# SIG=$(PKG_DIR)/$(PKG_NAME).asc

# DOC_DIR=$(PREFIX)/share/doc/$(PKG_NAME)

# pkg:
# 	mkdir -p $(PKG_DIR)

# $(PKG): 
# 	pkg
# 	git archive --output=$(PKG) --prefix=$(PKG_NAME)/ HEAD


# $(SIG): 
# 	$(PKG)
# 	gpg --sign --detach-sign --armor $(PKG)

# sign: $(SIG)

# clean:
# 	rm -f $(PKG) $(SIG)

# all: 
# 	$(PKG) $(SIG)

# tag:
# 	# git tag v$(VERSION)
# 	# git push --tags

# release: 
# 	$(PKG) $(SIG) tag

test:
	g v

install: copyfiles setup test

copyfiles:
	mkdir -p $(INSTALL_DIR)
	for dir in $(INSTALL_DIRS); do mkdir -p $(INSTALL_DIR)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(INSTALL_DIR)/$$file; done
	# mkdir -p $(DOC_DIR)
	# cp -r $(DOC_FILES) $(DOC_DIR)/

setup: 
	echo -n "\n#gg\n. $(INSTALL_DIR)/lib/bash-lambda/bash-lambda\n" >> ~/.profile
	echo -n 'export PATH=$$PATH:/usr/local/g' >> ~/.profile
	echo -n "\n#gg\n" >> ~/.profile
	# . ~/.profile

uninstall:
	rm -rf $(INSTALL_DIR)
	awk '!/\#gg[\s]*.*[\s]*\#gg/' ~/.profile > temp && mv temp ~/.profile
	# for file in $(INSTALL_FILES); do rm -f $(INSTALL_DIR)/$$file; done
	# rm -rf $(DOC_DIR)


# .PHONY:  
# 	build sign clean test tag release install uninstall all
.PHONY:
	test install copyfiles setup uninstall
