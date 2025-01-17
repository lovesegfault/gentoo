# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

MY_TESTDATA_COMMIT="887fb7a3e006f32b4979e0d55f2543abe78a42f1"

DESCRIPTION="Snowball compiler and stemming algorithms"
HOMEPAGE="https://snowballstem.org/ https://github.com/snowballstem/snowball/"
SRC_URI="https://github.com/snowballstem/snowball/archive/v${PV}.tar.gz -> ${P}.tar.gz
	test? ( https://github.com/snowballstem/snowball-data/archive/${MY_TESTDATA_COMMIT}.tar.gz -> snowball-data-${MY_TESTDATA_COMMIT}.tar.gz )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~ppc-macos ~sparc-solaris ~sparc64-solaris"
IUSE="static-libs test"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="dev-lang/perl
	test? ( virtual/libiconv )"
RESTRICT="!test? ( test )"

S="${WORKDIR}/snowball-${PV}"

PATCHES=(
	"${FILESDIR}/${P}-shared-library.patch"
)

src_compile() {
	export CC=$(tc-getCC)
	export AR=$(tc-getAR)
	default
}

src_install() {
	dodoc README.rst NEWS

	dobin stemwords

	doheader include/libstemmer.h

	dolib.so libstemmer.so.${PV}
	dolib.so libstemmer.so.$(ver_cut 1)
	dolib.so libstemmer.so

	use static-libs && dolib.a libstemmer.a
}

src_test() {
	emake -j1 STEMMING_DATA="${WORKDIR}/snowball-data-${MY_TESTDATA_COMMIT}" check
}
