NAME=g
VERSION=0.01.02

DIRS=.
PREFIX?=/usr/local/lib
PROFILE?=~/.profile
INSTALL_DIR=$(PREFIX)/$(NAME)
#gets all files and folders excluding hidden dot files
INSTALL_DIRS=`find $(DIRS) \( ! -regex '.*/\..*' \) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) \( ! -regex '.*/\..*' \) -type f 2>/dev/null`

BASH_LAMBDA_DIR=/lib/bash-lambda/bash-lambda
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
	for dir in $(INSTALL_DIRS); do mkdir -p $(INSTALL_DIR)/$$dir; done
	for file in $(INSTALL_FILES); do cp $$file $(INSTALL_DIR)/$$file; done

setupenv: 
	#source bash-lamda lib and add g to path
	echo "#gg\n. $(INSTALL_DIR)/$(BASH_LAMBDA_DIR)" >> $(PROFILE)
	echo 'export PATH=$$PATH:$(INSTALL_DIR)' >> $(PROFILE)
	echo "#gg\n" >> $(PROFILE)
	chmod +x $(INSTALL_DIR)/$(NAME)
	chmod -R +x $(INSTALL_DIR)/$(COMMAND_DIR)
	echo "WIP install - please restart terminal session"
	#TODO: get rid of lamdba not found error, something not source profile properly
	# . $(PROFILE)
	# reset

removefiles:
	rm -rf $(INSTALL_DIR)

cleanenv:
	sed '/\#gg/,/\#gg/d' $(PROFILE) > temp && mv temp $(PROFILE)

.PHONY:
	build test install copyfiles setupconfig uninstall removefiles removeconfig
