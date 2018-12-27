PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker
PROJECT_VERSION = 3.0

DEPS += emqx emqx_retainer emqx_recon emqx_reloader emqx_dashboard emqx_management \
		emqx_auth_clientid emqx_auth_username emqx_auth_ldap emqx_auth_http \
        emqx_auth_mysql emqx_auth_pgsql emqx_auth_redis emqx_auth_mongo \
        emqx_sn emqx_coap emqx_lwm2m emqx_stomp emqx_plugin_template emqx_web_hook \
        emqx_auth_jwt emqx_statsd emqx_delayed_publish emqx_lua_hook push_broker

# emqx and plugins
dep_emqx            = git https://github.com/emqx/emqx v3.0-rc.4
dep_emqx_retainer   = git https://github.com/emqx/emqx-retainer v3.0-rc.4
dep_emqx_recon      = git https://github.com/emqx/emqx-recon v3.0-rc.4
dep_emqx_reloader   = git https://github.com/emqx/emqx-reloader v3.0-rc.4
dep_emqx_dashboard  = git https://github.com/emqx/emqx-dashboard v3.0-rc.4
dep_emqx_management = git https://github.com/emqx/emqx-management v3.0-rc.4
dep_emqx_statsd     = git https://github.com/emqx/emqx-statsd v3.0-rc.4
dep_emqx_delayed_publish = git https://github.com/emqx/emqx-delayed-publish v3.0-rc.4

dep_push_broker     = git git@github.com:claymcenter/push_broker master

# emq auth/acl plugins
dep_emqx_auth_clientid = git https://github.com/emqx/emqx-auth-clientid v3.0-rc.4
dep_emqx_auth_username = git https://github.com/emqx/emqx-auth-username v3.0-rc.4
dep_emqx_auth_ldap     = git https://github.com/emqx/emqx-auth-ldap v3.0-rc.4
dep_emqx_auth_http     = git https://github.com/emqx/emqx-auth-http v3.0-rc.4
dep_emqx_auth_mysql    = git https://github.com/emqx/emqx-auth-mysql v3.0-rc.4
dep_emqx_auth_pgsql    = git https://github.com/emqx/emqx-auth-pgsql v3.0-rc.4
dep_emqx_auth_redis    = git https://github.com/emqx/emqx-auth-redis v3.0-rc.4
dep_emqx_auth_mongo    = git https://github.com/emqx/emqx-auth-mongo v3.0-rc.4
dep_emqx_auth_jwt      = git https://github.com/emqx/emqx-auth-jwt v3.0-rc.4

# mqtt-sn, coap and stomp
dep_emqx_sn    = git https://github.com/emqx/emqx-sn v3.0-rc.4
dep_emqx_coap  = git https://github.com/emqx/emqx-coap v3.0-rc.4
dep_emqx_lwm2m = git https://github.com/emqx/emqx-lwm2m v3.0-rc.4
dep_emqx_stomp = git https://github.com/emqx/emqx-stomp v3.0-rc.4

# plugin template
dep_emqx_plugin_template = git https://github.com/emqx/emq-plugin-template v3.0-rc.4

# web_hook
dep_emqx_web_hook  = git https://github.com/emqx/emqx-web-hook v3.0-rc.4
dep_emqx_lua_hook  = git https://github.com/emqx/emqx-lua-hook v3.0-rc.4

# All emqx app names. Repo name, not Erlang app name
# By default, app name is the same as repo name with dash replaced by underscore.
# Otherwise define the dependency in regular erlang.mk style:
# DEPS += special_app
# dep_special_app = git https//github.com/emqx/some-name.git branch-or-tag
OUR_APPS = emqx emqx-retainer emqx-recon emqx-reloader emqx-dashboard emqx-management \
           emqx-auth-clientid emqx-auth-username emqx-auth-ldap emqx-auth-http \
           emqx-auth-mysql emqx-auth-pgsql emqx-auth-redis emqx-auth-mongo \
           emqx-sn emqx-coap emqx-lwm2m emqx-stomp emqx-plugin-template emqx-web-hook \
           emqx-auth-jwt emqx-statsd emqx-delayed-publish emqx-lua-hook

# Auto patch would make the git status dirty which will in turn affect app version
NO_AUTOPATCH = emqx

# Default release profiles
RELX_OUTPUT_DIR ?= _rel
REL_PROFILE ?= dev

# Default version for all OUR_APPS
## This is either a tag or branch name for ALL dependencies
EMQX_DEPS_DEFAULT_VSN ?= v3.0-rc.5

dash = -
uscore = _

# Make Erlang app name from repo name.
# Replace dashes with underscores
app_name = $(subst $(dash),$(uscore),$(1))

# set emqx_app_name_vsn = x.y.z to override default version
app_vsn = $(if $($(call app_name,$(1))_vsn),$($(call app_name,$(1))_vsn),$(EMQX_DEPS_DEFAULT_VSN))

DEPS += $(foreach dep,$(OUR_APPS),$(call app_name,$(dep)))

# Inject variables like
# dep_app_name = git-emqx https://github.com/emqx/app-name branch-or-tag
# for erlang.mk
$(foreach dep,$(OUR_APPS),$(eval dep_$(call app_name,$(dep)) = git-emqx https://github.com/emqx/$(dep) $(call app_vsn,$(dep))))

GIT_VSN = $(shell git --version | grep -oE "[0-9]{1,2}\.[0-9]{1,2}")
GIT_VSN_17_COMP = $(shell echo -e "$(GIT_VSN)\n1.7" | sort -V | tail -1)
ifeq ($(GIT_VSN_17_COMP),1.7)
	MAYBE_SHALLOW =
else
	MAYBE_SHALLOW = -c advice.detachedHead=false --depth 1
endif

# Override default git full-clone with depth=1 shallow-clone
ifeq ($(GIT_VSN_17_COMP),1.7)
define dep_fetch_git-emqx
	git clone -q -n -- $(call dep_repo,$(1)) $(DEPS_DIR)/$(call dep_name,$(1)); \
		cd $(DEPS_DIR)/$(call dep_name,$(1)) && git checkout -q $(call dep_commit,$(1))
endef
else
define dep_fetch_git-emqx
	git clone -q -c advice.detachedHead=false --depth 1 -b $(call dep_commit,$(1)) -- $(call dep_repo,$(1)) $(DEPS_DIR)/$(call dep_name,$(1))
endef
endif

# Add this dependency before including erlang.mk
all:: OTP_21_OR_NEWER

# COVER = true
include erlang.mk

# Fail fast in case older than OTP 21
.PHONY: OTP_21_OR_NEWER
OTP_21_OR_NEWER:
	@erl -noshell -eval "R = list_to_integer(erlang:system_info(otp_release)), halt(if R >= 21 -> 0; true -> 1 end)"

# Compile options
ERLC_OPTS += +warn_export_all +warn_missing_spec +warn_untyped_record

plugins:
	@rm -rf rel
	@mkdir -p rel/conf/plugins/ rel/schema/
	@for conf in $(DEPS_DIR)/*/etc/*.conf* ; do \
		if [ "emqx.conf" = "$${conf##*/}" ] ; then \
			cp $${conf} rel/conf/ ; \
		elif [ "acl.conf" = "$${conf##*/}" ] ; then \
			cp $${conf} rel/conf/ ; \
		elif [ "ssl_dist.conf" = "$${conf##*/}" ] ; then \
			cp $${conf} rel/conf/ ; \
		else \
			cp $${conf} rel/conf/plugins ; \
		fi ; \
	done
	@for schema in $(DEPS_DIR)/*/priv/*.schema ; do \
		cp $${schema} rel/schema/ ; \
	done

app:: plugins vars-ln

vars-ln:
	ln -s -f vars-$(REL_PROFILE).config vars.config
