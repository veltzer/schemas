##############
# parameters #
##############
# do you want to show the commands executed ?
DO_MKDBG:=0
# do you want dependency on the Makefile itself ?
DO_ALLDEP:=1
# do you want json checking?
DO_CHECK_JSON:=1
# do you want yaml checking?
DO_CHECK_YAML:=1
# do you want to check the javascript code?
DO_JS_CHECK:=1

########
# code #
########
JSON:=$(shell find docs/json -type f -and -name "*.json")
JSON_CHECK:=$(addprefix out/check/,$(addsuffix .stamp, $(JSON)))
YAML:=$(shell find docs/yaml -type f -and -name "*.yaml")
YAML_CHECK:=$(addprefix out/check/,$(addsuffix .stamp, $(YAML)))
HTML_SRC:=$(shell find docs -type f -and -name "*.html")
HTML_CHECK:=$(addprefix out/, $(addsuffix .check, $(basename $(HTML_SRC))))

# silent stuff
ifeq ($(DO_MKDBG),1)
Q:=
# we are not silent in this branch
else # DO_MKDBG
Q:=@
#.SILENT:
endif # DO_MKDBG

ifeq ($(DO_CHECK_JSON),1)
ALL+=$(JSON_CHECK)
endif # DO_CHECK_JSON

ifeq ($(DO_CHECK_YAML),1)
ALL+=$(YAML_CHECK)
endif # DO_CHECK_YAML

ifeq ($(DO_JS_CHECK),1)
ALL+=$(HTML_CHECK)
endif # DO_JS_CHECK

#########
# rules #
#########
.PHONY: all
all: $(ALL)
	@true

.PHONY: debug
debug:
	$(info ALL is $(ALL))
	$(info JSON is $(JSON))
	$(info JSON_CHECK is $(JSON_CHECK))
	$(info YAML is $(YAML))
	$(info YAML_JSON is $(YAML_JSON))
	$(info HTML_SRC is $(HTML_SRC))
	$(info HTML_CHECK is $(HTML_CHECK))

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
$(JSON_CHECK): out/check/%.stamp: % scripts/validate_schema.py
	$(info doing [$@])
	$(Q)pymakehelper only_print_on_error python -m json.tool $<
	$(Q)pymakehelper only_print_on_error check-jsonschema --schemafile $$(yq -r '.["$$schema"]' $<)  $<
	$(Q)pymakehelper only_print_on_error scripts/validate_schema.py $<
	$(Q)pymakehelper touch_mkdir $@
# $(Q)pymakehelper only_print_on_error check-jsonschema --check-metaschema $<
# $(Q)node_modules/.bin/ajv compile -r "docs/json/shared/common.json" -c ajv-formats -s $<
$(YAML_CHECK): out/check/%.stamp: %
	$(info doing [$@])
	$(Q)pycmdtools validate_yaml $<
	$(Q)pymakehelper touch_mkdir $@
$(HTML_CHECK): out/%.check: %.html .jshintrc
	$(info doing [$@])
	$(Q)node_modules/.bin/jshint --extract=auto $<
	$(Q)pymakehelper touch_mkdir $@

# $(JSON_VALIDATE): out/validate/%.stamp: %
# 	$(info doing [$@])
# 	$(Q)jsonschema -i $< schemas/json/$(basename $(notdir $@))
#	$(Q)pymakehelper touch_mkdir $@
# $(YAMLS_JSON): out/yaml2json/%.yaml: %
# 	$(info doing [$@])
# 	$(Q)mkdir -p $(dir $@)
# 	$(Q)yq . < $< > $@

##########
# alldep #
##########
ifeq ($(DO_ALLDEP),1)
.EXTRA_PREREQS+=$(foreach mk, ${MAKEFILE_LIST},$(abspath ${mk}))
endif # DO_ALLDEP
