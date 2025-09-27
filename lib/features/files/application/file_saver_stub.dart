import 'file_saver_interface.dart';

FileSaver createPlatformFileSaver() =>
    throw UnsupportedError('File saving is not supported on this platform');
