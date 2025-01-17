# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PHP_EXT_NAME="memcached"
DOCS=( ChangeLog README.markdown )

USE_PHP="php7-3 php7-4 php8-0"
inherit php-ext-pecl-r3

DESCRIPTION="Interface PHP with memcached via libmemcached library"
LICENSE="PHP-3.01"
SLOT="7"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="igbinary json sasl +session test"
REPO_COMMIT="9cd4a01d99b701a2c1a42799afe80635dcfecfe4"
SRC_URI="https://github.com/php-memcached-dev/php-memcached/archive/${REPO_COMMIT}.tar.gz -> ${P}.tar.gz"

RESTRICT="!test? ( test )"

COMMON_DEPEND=">=dev-libs/libmemcached-1.0.14[sasl(-)?]
	sys-libs/zlib
"

RDEPEND="
	php_targets_php7-3? (
		${COMMON_DEPEND} dev-lang/php:7.3[session(-)?,json(-)?]
		igbinary? ( dev-php/igbinary[php_targets_php7-3(-)] )
	)
	php_targets_php7-4? (
		${COMMON_DEPEND} dev-lang/php:7.4[session(-)?,json(-)?]
		igbinary? ( dev-php/igbinary[php_targets_php7-4(-)] )
	)
	php_targets_php8-0? (
		${COMMON_DEPEND} dev-lang/php:8.0[session(-)?]
		igbinary? ( dev-php/igbinary[php_targets_php8-0(-)] )
	)"
DEPEND="${RDEPEND} test? ( net-misc/memcached )"

src_unpack() {
	default
	mv "${WORKDIR}/php-memcached-${REPO_COMMIT}" "${S}" || die
	# These tests always fail and only exist for "experimental" features
	# Not present in 3.1.5 release
	rm -r "${S}/tests/experimental/" || die
}

src_configure() {
	local PHP_EXT_ECONF_ARGS="--enable-memcached
		$(use_enable session memcached-session)
		$(use_enable sasl memcached-sasl)
		$(use_enable json memcached-json)
		$(use_enable igbinary memcached-igbinary)"

	php-ext-source-r3_src_configure
}

src_test() {
	local memcached_opts=( -d -P "${T}/memcached.pid" -p 11211 -l 127.0.0.1 )
	[[ ${EUID} == 0 ]] && memcached_opts+=( -u portage )
	memcached "${memcached_opts[@]}" || die "Can't start memcached test server"

	local exit_status
	php-ext-source-r3_src_test
	exit_status=$?

	kill "$(<"${T}/memcached.pid")"
	return ${exit_status}
}
