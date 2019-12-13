BUILD_OTA = "${@bb.utils.contains('DISTRO_FEATURES', 'singleboot', 'true', 'false', d)}"
