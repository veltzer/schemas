##############
# parameters #
##############
# do you want to show the commands executed ?
DO_MKDBG:=0

########
# code #
########
JSON:=$(shell find docs/json -type f -and -name "*.json")
JSON_CHECK:=$(addprefix out/check/,$(addsuffix .stamp, $(JSON)))
YAML:=$(shell find docs/yaml -type f -and -name "*.yaml")
YAML_CHECK:=$(addprefix out/check/,$(addsuffix .stamp, $(YAML)))

# silent stuff
ifeq ($(DO_MKDBG),1)
Q:=
# we are not silent in this branch
else # DO_MKDBG
Q:=@
#.SILENT:
endif # DO_MKDBG

#########
# rules #
#########
.PHONY: all
all: $(JSON_CHECK) $(YAML_CHECK)

.PHONY: debug
debug:
	$(info JSON is $(JSON))
	$(info JSON_CHECK is $(JSON_CHECK))
	$(info YAML is $(YAML))
	$(info YAML_JSON is $(YAML_JSON))

.PHONY: clean
clean:
	$(Q)rm -rf out
.PHONY: clean_hard
clean_hard:
	$(info doing [$@])
	$(Q)git clean -qffxd

############
# patterns #
############
$(JSON_CHECK): out/check/%.stamp: %
	$(info doing [$@])
	$(Q)python -m json.tool $< > /dev/null
	$(Q)mkdir -p $(dir $@)
	$(Q)touch $@
$(YAML_CHECK): out/check/%.stamp: %
	$(info doing [$@])
	$(Q)pycmdtools validate_yaml $<
	$(Q)mkdir -p $(dir $@)
	$(Q)touch $@

# $(JSON_VALIDATE): out/validate/%.stamp: %
# 	$(info doing [$@])
# 	$(Q)mkdir -p $(dir $@)
# 	$(Q)jsonschema -i $< schemas/json/$(basename $(notdir $@))
# 	$(Q)touch $@
# $(YAMLS_JSON): out/yaml2json/%.yaml: %
# 	$(info doing [$@])
# 	$(Q)mkdir -p $(dir $@)
# 	$(Q)yq . < $< > $@
