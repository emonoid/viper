import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class ProjectController {
  late Directory projectRoot;

  /// Initialize project root folder
  Future<void> initProject(String projectName) async {
    final appDir = await getApplicationDocumentsDirectory();
    projectRoot = Directory('${appDir.path}/$projectName');
    if (!await projectRoot.exists()) {
      await projectRoot.create(recursive: true);
    }
  }

  /// Create a folder inside the project
  Future<Directory> createFolder(String folderName, [String? folderPath]) async {
    final path = folderPath != null
        ? '${projectRoot.path}/$folderPath/$folderName'
        : '${projectRoot.path}/$folderName';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Create a file inside the project
  Future<File> createFile(String filenameWithExtension, [String? folderPath]) async {
    final path = folderPath != null
        ? '${projectRoot.path}/$folderPath/$filenameWithExtension'
        : '${projectRoot.path}/$filenameWithExtension';
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  /// Add or overwrite code in a file
  Future<void> addCodeInFile(String filePath, String fileName, String code) async {
    final file = File('${projectRoot.path}/$filePath/$fileName');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(code);
  }

  /// Helper to read code (optional)
  Future<String> readCode(String filePath, String fileName) async {
    final file = File('${projectRoot.path}/$filePath/$fileName');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }

  /// Export project as ZIP and return the file path
  Future<String> exportProject() async {
    final archive = Archive();

    // Recursively add files from project folder
    await for (var entity in projectRoot.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final relativePath = entity.path.replaceFirst(projectRoot.path + '/', '');
        final data = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, data.length, data));
      }
    }

    final zipData = ZipEncoder().encode(archive);

    // Save zip in Downloads folder
    final downloadsDir = await getDownloadsDirectory();
    final zipPath = '${downloadsDir?.path ?? projectRoot.path}/${projectRoot.uri.pathSegments.last}.zip';

    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(Uint8List.fromList(zipData!));

    return zipPath;
  }
}
