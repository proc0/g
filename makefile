NAME=g
CONFIG?=g.conf.yml
PREFIX?=/usr/local/lib
PROFILE?=~/.profile
XHOME=$(PREFIX)/$(NAME)
XPATH=$(PREFIX)/$(NAME)/$(NAME)
#get all files and folders excluding hidden dot files
DIRS=`find . \( ! -regex '.*/\..*' \) -type d 2>/dev/null`
FILES=`find . \( ! -regex '.*/\..*' \) -type f 2>/dev/null`

build: uninstall install
install: copyfiles setupenv
uninstall: removefiles cleanenv

copyfiles:
	mkdir -p $(XHOME)
	#copy config on install - TODO make this work
	#[ ! -f ./$(CONFIG) ] && [ ! -d cfg ] && \
	#cp ./cfg/$(CONFIG) "$(XHOME)/$(CONFIG)"
	for dir in $(DIRS); do mkdir -p $(XHOME)/$$dir; done
	for file in $(FILES); do cp $$file $(XHOME)/$$file; done

setupenv: 
	echo "#adding g to path" >> $(PROFILE)
	echo "export PATH=$$PATH:$(XHOME)" >> $(PROFILE)
	chmod +x $(XPATH)

cleanenv:
	sed -i.old '/^export.*\/lib\/g\s*/d' $(PROFILE)
	sed -i.old '/^[#*-]?\{0,1\}adding g to path\s*/d' $(PROFILE)

removefiles:
	rm -rf $(XHOME)

.PHONY:
	test 
	build 
	install
	uninstall
	copyfiles
	cleanenv
	removefiles
	# setupconfig
	# removeconfig

#TODO: add packaging? add versioned packages?
# TEMP?=~/.tmp
# PKG_DIR=pkg
# PKG_NAME=$(NAME)-$(VERSION)
# PKG=$(PKG_DIR)/$(PKG_NAME).tar.gz
# SIG=$(PKG_DIR)/$(PKG_NAME).asc

# DOC_DIR=$(PREFIX)/share/doc/$(PKG_NAME)

# test: g v

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