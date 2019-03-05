SHELL := /bin/bash

OUTPUT_DIR = ./proto
PKG_NAME = bbf-pppoe
YANGROOT = ./yang
PROTOPATH = $(OUTPUT_DIR)/$(PKG_NAME)
PROTOGEN = $(GOPATH)/src/github.com/openconfig/ygot/proto_generator/protogenerator.go

yangpath = $(YANGROOT)/standard/ietf/RFC/,$\
	$(YANGROOT)/standard/bbf/standard/common,$\
	$(YANGROOT)/standard/bbf/standard/interface
bbf-pppoe = $(YANGROOT)/standard/bbf/standard/networking/bbf-pppoe-intermediate-agent.yang
models = $(YANGROOT)/standard/bbf/standard/interface/bbf-if-type.yang $\
	$(YANGROOT)/standard/ietf/RFC/ietf-interfaces.yang $\
	$(YANGROOT)/standard/bbf/standard/common/bbf-yang-types.yang $\
	$(YANGROOT)/standard/bbf/standard/interface/bbf-if-type.yang $\
	$(bbf-pppoe)
protos = $(PROTOPATH)/bbf-pppoe.proto $\
	$(PROTOPATH)/bbf_pppoe_intermediate_agent/bbf_pppoe_intermediate_agent.proto $\
	$(PROTOPATH)/enums/enums.proto $\
	$(PROTOPATH)/ietf_interfaces/ietf_interfaces.proto

all: $(protos)

.PHONY: patch unpatch
patch:
	git apply patches/bbf-pppoe-intermediate-agent.patch

.ONESHELL:
unpatch:
	pushd .
	cd $(YANGROOT)
	git reset --hard
	git submodule update -f --init
	popd


$(protos): $(models)
	go run $(PROTOGEN) \
		-generate_fakeroot \
		-path=$(yangpath) \
		-output_dir=proto \
	        -package_name=bbf-pppoe \
		$(bbf-pppoe)

.PHONY: clean
clean:
	rm -rf $(PROTOPATH)/*
