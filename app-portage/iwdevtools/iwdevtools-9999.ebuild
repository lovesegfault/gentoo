# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 meson optfeature

DESCRIPTION="Small tools to aid with Gentoo development, primarily intended for QA"
HOMEPAGE="https://github.com/ionenwks/iwdevtools"
EGIT_REPO_URI="https://github.com/ionenwks/iwdevtools.git"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS=""
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	app-misc/pax-utils
	app-portage/portage-utils
	sys-apps/diffutils
	sys-apps/file
	sys-apps/portage
	sys-apps/util-linux"
BDEPEND="test? ( ${RDEPEND} )"

src_configure() {
	meson_src_configure -Ddocdir=${PF}
}

pkg_postinst() {
	optfeature "detecting potential ABI issues using abidiff" dev-util/libabigail

	if [[ ! ${REPLACING_VERSIONS} ]]; then
		elog "To (optionally) integrate with portage, inspect the .bashrc files installed"
		elog "at ${EROOT}/usr/share/${PN}. If not already using a bashrc, you can use"
		elog "the example bashrc directly by creating a symlink:"
		elog
		elog "    ln -s ../../../usr/share/${PN}/bashrc ${EROOT}/etc/portage/bashrc"
		elog
		elog "See ${EROOT}/usr/share/doc/${PF}/README.rst* for info on tools."
	fi
}
