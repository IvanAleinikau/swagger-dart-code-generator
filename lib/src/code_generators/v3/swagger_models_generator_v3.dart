import 'package:swagger_dart_code_generator/src/code_generators/swagger_models_generator.dart';
import 'package:swagger_dart_code_generator/src/extensions/string_extension.dart';
import 'package:swagger_dart_code_generator/src/models/generator_options.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/responses/swagger_schema.dart';
import 'package:swagger_dart_code_generator/src/swagger_models/swagger_root.dart';

class SwaggerModelsGeneratorV3 extends SwaggerModelsGenerator {
  SwaggerModelsGeneratorV3(GeneratorOptions options) : super(options);

  @override
  String generate(SwaggerRoot root, String fileName) {
    final components = root.components;
    final schemas = components?.schemas;

    return generateBase(root, fileName, schemas ?? {}, true);
  }

  @override
  String generateResponses(SwaggerRoot root, String fileName) {
    final components = root.components;

    if (components == null) {
      return '';
    }

    final responses = components.responses;

    var result = <String, SwaggerSchema>{};

    final allModelNames =
        components.schemas.keys.map((e) => getValidatedClassName(e));

    for (var key in responses.keys) {
      if (!allModelNames.contains(key)) {
        final schema = responses[key];

        if (schema != null && schema.ref.isEmpty) {
          result.addAll({key: schema});
        }
      }
    }

    return generateBase(root, fileName, result, false);
  }

  @override
  String generateRequestBodies(SwaggerRoot root, String fileName) {
    final components = root.components;
    final requestBodies = components?.requestBodies ?? {};

    requestBodies.addAll(getRequestBodiesFromRequests(root));

    if (requestBodies.isEmpty) {
      return '';
    }

    var result = <String, SwaggerSchema>{};

    final allModelNames =
        components!.schemas.keys.map((e) => getValidatedClassName(e));

    for (var key in requestBodies.keys) {
      if (!allModelNames.contains(key)) {
        final req = requestBodies[key];

        if (req != null) {
          result.addAll({key: req});
        }
      }
    }

    return generateBase(root, fileName, result, false);
  }

  @override
  List<String> getAllListEnumNames(SwaggerRoot root) {
    final results = getEnumsFromRequests(root).map((e) => e.name).toList();

    final components = root.components;

    final schemas = components?.schemas;

    if (schemas != null) {
      schemas.forEach((className, schema) {
        if (schema.isListEnum) {
          results.add(getValidatedClassName(className.capitalize));
          return;
        }
      });
    }

    final resultsWithPrefix = results.map((element) {
      return 'enums.$element';
    }).toList();

    return resultsWithPrefix;
  }

  @override
  String getExtendsString(SwaggerSchema schema) {
    final allOf = schema.allOf;
    if (allOf.isNotEmpty) {
      final refItem = allOf.firstWhere((m) => m.hasRef);

      final ref = refItem.ref.split('/').last;

      final className = getValidatedClassName(ref);

      return 'extends $className';
    }

    return '';
  }
}
