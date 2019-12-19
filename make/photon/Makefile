# Makefile for a harbor project
#
# Targets:
#
# build: 	build harbor photon images
# clean:	clean core and jobservice harbor images

DOCKER_USERNAME=packyzbq
DOCKER_PASSWD=Qw./a111zbq

# common
SHELL := /bin/bash
BUILDPATH=$(CURDIR)
MAKEPATH=$(BUILDPATH)/make
MAKEDEVPATH=$(MAKEPATH)/dev
SRCPATH=./src
TOOLSPATH=$(CURDIR)/tools
SEDCMD=$(shell which sed)
WGET=$(shell which wget)
BUILDBIN=true

# docker parameters
DOCKERCMD=$(shell which docker)
DOCKERBUILD=$(DOCKERCMD) build --pull
DOCKERRMIMAGE=$(DOCKERCMD) rmi
DOCKERIMASES=$(DOCKERCMD) images

# binary
CORE_SOURCECODE=$(SRCPATH)/core
CORE_BINARYPATH=$(MAKEDEVPATH)/core
CORE_BINARYNAME=harbor_core
JOBSERVICESOURCECODE=$(SRCPATH)/jobservice
JOBSERVICEBINARYPATH=$(MAKEDEVPATH)/jobservice
JOBSERVICEBINARYNAME=harbor_jobservice

# photon dockerfile
DOCKERFILEPATH=$(MAKEPATH)/photon
VERSIONTAG=arm64

DOCKERFILEPATH_PREPARE=$(DOCKERFILEPATH)/prepare
DOCKERFILENAME_PREPARE=Dockerfile
DOCKERIMAGENAME_PREPARE=goharbor/prepare

DOCKERFILEPATH_PORTAL=$(DOCKERFILEPATH)/portal
DOCKERFILENAME_PORTAL=Dockerfile
DOCKERIMAGENAME_PORTAL=harbor-portal

DOCKERFILEPATH_CORE=$(DOCKERFILEPATH)/core
DOCKERFILENAME_CORE=Dockerfile
DOCKERIMAGENAME_CORE=harbor-core

DOCKERFILEPATH_JOBSERVICE=$(DOCKERFILEPATH)/jobservice
DOCKERFILENAME_JOBSERVICE=Dockerfile
DOCKERIMAGENAME_JOBSERVICE=harbor-jobservice

DOCKERFILEPATH_LOG=$(DOCKERFILEPATH)/log
DOCKERFILENAME_LOG=Dockerfile
DOCKERIMAGENAME_LOG=harbor-log

DOCKERFILEPATH_DB=$(DOCKERFILEPATH)/db
DOCKERFILENAME_DB=Dockerfile
DOCKERIMAGENAME_DB=harbor-db

DOCKERFILEPATH_POSTGRESQL=$(DOCKERFILEPATH)/postgresql
DOCKERFILENAME_POSTGRESQL=Dockerfile
DOCKERIMAGENAME_POSTGRESQL=postgresql-photon

DOCKERFILEPATH_CLAIR=$(DOCKERFILEPATH)/clair
DOCKERFILENAME_CLAIR=Dockerfile
DOCKERIMAGENAME_CLAIR=clair-photon

DOCKERFILEPATH_NGINX=$(DOCKERFILEPATH)/nginx
DOCKERFILENAME_NGINX=Dockerfile
DOCKERIMAGENAME_NGINX=harbor-nginx

DOCKERFILEPATH_REG=$(DOCKERFILEPATH)/registry
DOCKERFILENAME_REG=Dockerfile
DOCKERIMAGENAME_REG=harbor-registry-photon

DOCKERFILEPATH_REGISTRYCTL=$(DOCKERFILEPATH)/registryctl
DOCKERFILENAME_REGISTRYCTL=Dockerfile
DOCKERIMAGENAME_REGISTRYCTL=harbor-harbor-registryctl

DOCKERFILEPATH_NOTARY=$(DOCKERFILEPATH)/notary
DOCKERFILENAME_NOTARYSIGNER=signer.Dockerfile
DOCKERIMAGENAME_NOTARYSIGNER=harbor-notary-signer-photon
DOCKERFILENAME_NOTARYSERVER=server.Dockerfile
DOCKERIMAGENAME_NOTARYSERVER=harbor-notary-server-photon

DOCKERFILEPATH_REDIS=$(DOCKERFILEPATH)/redis
DOCKERFILENAME_REDIS=Dockerfile
DOCKERIMAGENAME_REDIS=harbor-redis-photon

DOCKERFILEPATH_MIGRATOR=$(TOOLSPATH)/migration
DOCKERFILENAME_MIGRATOR=Dockerfile
DOCKERIMAGENAME_MIGRATOR=harbor-harbor-migrator

# for chart server (chartmuseum)
DOCKERFILEPATH_CHART_SERVER=$(DOCKERFILEPATH)/chartserver
DOCKERFILENAME_CHART_SERVER=Dockerfile
CHART_SERVER_CODE_BASE=https://github.com/helm/chartmuseum.git
CHART_SERVER_MAIN_PATH=cmd/chartmuseum
CHART_SERVER_BIN_NAME=chartm

_build_prepare:
	@echo "building prepare container for photon..."
	@$(DOCKERBUILD) -f $(DOCKERFILEPATH_PREPARE)/$(DOCKERFILENAME_PREPARE) -t $(DOCKERIMAGENAME_PREPARE):$(VERSIONTAG) .
	@echo "Done."

_build_db:
	@echo "building db container for photon..."
	@$(DOCKERBUILD) -f $(DOCKERFILEPATH_DB)/$(DOCKERFILENAME_DB) -t $(DOCKERIMAGENAME_DB):$(VERSIONTAG) .
	@echo "Done."
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_DB):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-db:arm64
	@docker push $(DOCKER_USERNAME)/harbor-db:arm64

_build_portal:
	@echo "building portal container for photon..."
	$(DOCKERBUILD) --build-arg npm_registry=$(NPM_REGISTRY) -f $(DOCKERFILEPATH_PORTAL)/$(DOCKERFILENAME_PORTAL) -t $(DOCKERIMAGENAME_PORTAL):$(VERSIONTAG) .
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_PORTAL):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-portal:arm64
	@docker push $(DOCKER_USERNAME)/harbor-portal:arm64
	@echo "Done."

_build_core:
	@echo "building core container for photon..."
	@$(DOCKERBUILD) -f $(DOCKERFILEPATH_CORE)/$(DOCKERFILENAME_CORE) -t $(DOCKERIMAGENAME_CORE):$(VERSIONTAG) .
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_CORE):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-core:arm64
	@docker push $(DOCKER_USERNAME)/harbor-core:arm64
	@echo "Done."

_build_jobservice:
	@echo "building jobservice container for photon..."
	@$(DOCKERBUILD) -f $(DOCKERFILEPATH_JOBSERVICE)/$(DOCKERFILENAME_JOBSERVICE) -t $(DOCKERIMAGENAME_JOBSERVICE):$(VERSIONTAG) .
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_JOBSERVICE):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-jobservice:arm64
	@docker push $(DOCKER_USERNAME)/harbor-jobservice:arm64
	@echo "Done."

_build_log:
	@echo "building log container for photon..."
	$(DOCKERBUILD) -f $(DOCKERFILEPATH_LOG)/$(DOCKERFILENAME_LOG) -t $(DOCKERIMAGENAME_LOG):$(VERSIONTAG) .
	@echo "Done."

_build_clair:
	@if [ "$(CLAIRFLAG)" = "true" ] ; then \
		if [ "$(BUILDBIN)" != "true" ] ; then \
			rm -rf $(DOCKERFILEPATH_CLAIR)/binary && mkdir -p $(DOCKERFILEPATH_CLAIR)/binary && \
			$(call _get_binary, https://storage.googleapis.com/harbor-builds/bin/clair/release2.0-$(CLAIRVERSION)/clair, $(DOCKERFILEPATH_CLAIR)/binary/clair); \
		else \
			cd $(DOCKERFILEPATH_CLAIR) && $(DOCKERFILEPATH_CLAIR)/builder $(CLAIRVERSION) && cd - ; \
		fi ; \
		echo "building clair container for photon..." ; \
		$(DOCKERBUILD) -f $(DOCKERFILEPATH_CLAIR)/$(DOCKERFILENAME_CLAIR) -t $(DOCKERIMAGENAME_CLAIR):$(CLAIRVERSION)-$(VERSIONTAG) . ; \
		rm -rf $(DOCKERFILEPATH_CLAIR)/binary; \
		echo "Done." ; \
	fi

_build_chart_server:
	@if [ "$(CHARTFLAG)" = "true" ] ; then \
		if [ "$(BUILDBIN)" != "true" ] ; then \
			rm -rf $(DOCKERFILEPATH_CHART_SERVER)/binary && mkdir -p $(DOCKERFILEPATH_CHART_SERVER)/binary && \
			$(call _get_binary, https://storage.googleapis.com/harbor-builds/bin/chartmuseum/release-$(CHARTMUSEUMVERSION)/chartm, $(DOCKERFILEPATH_CHART_SERVER)/binary/chartm); \
		else \
			cd $(DOCKERFILEPATH_CHART_SERVER) && $(DOCKERFILEPATH_CHART_SERVER)/builder $(GOBUILDIMAGE) $(CHART_SERVER_CODE_BASE) $(CHARTMUSEUMVERSION) $(CHART_SERVER_MAIN_PATH) $(CHART_SERVER_BIN_NAME) && cd - ; \
		fi ; \
		echo "building chartmuseum container for photon..." ; \
		$(DOCKERBUILD) -f $(DOCKERFILEPATH_CHART_SERVER)/$(DOCKERFILENAME_CHART_SERVER) -t $(DOCKERIMAGENAME_CHART_SERVER):$(VERSIONTAG) . ; \
		rm -rf $(DOCKERFILEPATH_CHART_SERVER)/binary; \
		echo "Done." ; \
	fi

_build_nginx:
	@echo "building nginx container for photon..."
	@$(DOCKERBUILD) -f $(DOCKERFILEPATH_NGINX)/$(DOCKERFILENAME_NGINX) -t $(DOCKERIMAGENAME_NGINX):$(VERSIONTAG) .
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_NGINX):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-nginx:arm64
	@docker push $(DOCKER_USERNAME)/harbor-nginx:arm64
	@echo "Done."

_build_notary:
	@if [ "$(NOTARYFLAG)" = "true" ] ; then \
		if [ "$(BUILDBIN)" != "true" ] ; then \
			rm -rf $(DOCKERFILEPATH_NOTARY)/binary && mkdir -p $(DOCKERFILEPATH_NOTARY)/binary && \
			$(call _get_binary, https://storage.googleapis.com/harbor-builds/bin/notary/release-$(NOTARYVERSION)/binary-bundle.tgz, $(DOCKERFILEPATH_NOTARY)/binary-bundle.tgz); \
			cd $(DOCKERFILEPATH_NOTARY) && tar -zvxf binary-bundle.tgz && cd - ; \
		else \
			cd $(DOCKERFILEPATH_NOTARY) && $(DOCKERFILEPATH_NOTARY)/builder $(NOTARYVERSION) $(NOTARYMIGRATEVERSION) && cd - ; \
		fi ; \
		echo "building notary container for photon..."; \
		chmod 655 $(DOCKERFILEPATH_NOTARY)/binary/notary-signer && $(DOCKERBUILD) -f $(DOCKERFILEPATH_NOTARY)/$(DOCKERFILENAME_NOTARYSIGNER) -t $(DOCKERIMAGENAME_NOTARYSIGNER):$(NOTARYVERSION)-$(VERSIONTAG) . ; \
		chmod 655 $(DOCKERFILEPATH_NOTARY)/binary/notary-server && $(DOCKERBUILD) -f $(DOCKERFILEPATH_NOTARY)/$(DOCKERFILENAME_NOTARYSERVER) -t $(DOCKERIMAGENAME_NOTARYSERVER):$(NOTARYVERSION)-$(VERSIONTAG) . ; \
		rm -rf $(DOCKERFILEPATH_NOTARY)/binary; \
		echo "Done."; \
	fi

_build_registry:
	@if [ "$(BUILDBIN)" != "true" ] ; then \
		rm -rf $(DOCKERFILEPATH_REG)/binary && mkdir -p $(DOCKERFILEPATH_REG)/binary && \
		$(call _get_binary, https://storage.googleapis.com/harbor-builds/bin/registry/release-$(REGISTRYVERSION)/registry, $(DOCKERFILEPATH_REG)/binary/registry); \
	else \
		cd $(DOCKERFILEPATH_REG) && $(DOCKERFILEPATH_REG)/builder v2.7.0 && cd - ; \
	fi
	@echo "building registry container for photon..."
	@chmod 655 $(DOCKERFILEPATH_REG)/binary/registry && $(DOCKERBUILD) -f $(DOCKERFILEPATH_REG)/$(DOCKERFILENAME_REG) -t $(DOCKERIMAGENAME_REG):$(VERSIONTAG) .
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_REG):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-registry:arm64
	@docker push $(DOCKER_USERNAME)/harbor-registry:arm64
	@echo "Done."

_build_registryctl:
	@echo "building registry controller for photon..."
	@$(DOCKERBUILD) -f $(DOCKERFILEPATH_REGISTRYCTL)/$(DOCKERFILENAME_REGISTRYCTL) -t $(DOCKERIMAGENAME_REGISTRYCTL):$(VERSIONTAG) .
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_REGISTRYCTL):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-registryctl:arm64
	@docker push $(DOCKER_USERNAME)/harbor-registryctl:arm64
	@rm -rf $(DOCKERFILEPATH_REG)/binary
	@echo "Done."

_build_redis:
	@echo "building redis container for photon..."
	@$(DOCKERBUILD) -f $(DOCKERFILEPATH_REDIS)/$(DOCKERFILENAME_REDIS) -t $(DOCKERIMAGENAME_REDIS):$(VERSIONTAG) .
	@echo "$(DOCKER_PASSWD)"| docker login -u "$(DOCKER_USERNAME)" --password-stdin
	@docker tag $(DOCKERIMAGENAME_REDIS):$(VERSIONTAG) $(DOCKER_USERNAME)/harbor-redis:arm64
	@docker push $(DOCKER_USERNAME)/harbor-redis:arm64
	@echo "Done."

_build_migrator:
	@if [ "$(MIGRATORFLAG)" = "true" ] ; then \
		echo "building db migrator container for photon..."; \
		cd $(DOCKERFILEPATH_MIGRATOR) && $(DOCKERBUILD) -f $(DOCKERFILEPATH_MIGRATOR)/$(DOCKERFILENAME_MIGRATOR) -t $(DOCKERIMAGENAME_MIGRATOR):$(MIGRATORVERSION) . ; \
		echo "Done."; \
	fi

define _get_binary
	$(WGET) --timeout 30 --no-check-certificate $1 -O $2
endef

#build: _build_prepare _build_db _build_portal _build_core _build_jobservice _build_log _build_nginx _build_registry _build_registryctl _build_notary _build_clair _build_redis _build_migrator _build_chart_server
build:   _build_registry _build_registryctl _build_redis _build_chart_server

cleanimage:
	@echo "cleaning image for photon..."
	- $(DOCKERRMIMAGE) -f $(DOCKERIMAGENAME_PORTAL):$(VERSIONTAG)
	- $(DOCKERRMIMAGE) -f $(DOCKERIMAGENAME_CORE):$(VERSIONTAG)
	- $(DOCKERRMIMAGE) -f $(DOCKERIMAGENAME_JOBSERVICE):$(VERSIONTAG)
	- $(DOCKERRMIMAGE) -f $(DOCKERIMAGENAME_LOG):$(VERSIONTAG)

.PHONY: clean
clean: cleanimage

