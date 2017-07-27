NAME=g
VERSION=0.01.2

DIRS=.
PREFIX?=/usr/local/lib
PROFILE?=~/.profile
CONFIGFILE?=g.conf.yml
TEMP?=~/.tmp
INSTALL_DIR=$(PREFIX)/$(NAME)
#gets all files and folders excluding hidden dot files
INSTALL_DIRS=`find $(DIRS) \( ! -regex '.*/\..*' \) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) \( ! -regex '.*/\..*' \) -type f 2>/dev/null`

COMMAND_DIR=/src/cmd
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

build: uninstall install

install: copyfiles setupenv

uninstall: removefiles cleanenv

copyfiles:
	mkdir -p $(INSTALL_DIR)
	#copy config on install - TODO make this work
	#[ ! -f ./$(CONFIGFILE) ] && [ ! -d cfg ] && \
	#cp ./cfg/$(CONFIGFILE) "$(INSTALL_DIR)/$(CONFIGFILE)"
	for dir in $(INSTALL_DIRS); do mkdir -p $(INSTALL_DIR)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(INSTALL_DIR)/$$file; done

setupenv: 
	echo "#adding g to path" >> $(PROFILE)
	echo "export PATH=$$PATH:$(INSTALL_DIR)" >> $(PROFILE)
	chmod +x $(INSTALL_DIR)/$(NAME)

removefiles:
	rm -rf $(INSTALL_DIR)

cleanenv:
	sed '/\#adding g to path\n.*$\n/d' $(PROFILE) > $(TEMP) && mv $(TEMP) $(PROFILE)

.PHONY:
	build test install copyfiles setupconfig cleanenv uninstall removefiles removeconfig
