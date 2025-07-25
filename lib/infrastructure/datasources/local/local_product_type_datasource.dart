import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:groceryhelper/infrastructure/services/talker_service.dart';
import '../../../shared/errors/errors.dart';
import '../../../domain/entities/product_type.dart';
import '../../../domain/enums/product_category.dart';
import '../../database/app_database.dart';

class LocalProductTypeDatasource {
  final AppDatabase _database;

  LocalProductTypeDatasource({required AppDatabase database}) : _database = database;

  Future<Either<AppError, List<ProductType>>> getAllProductTypes() async {
    try {
      final types = await _database.select(_database.productTypesTable).get();
      return right(types.map((type) => _mapToProductType(type)).toList());
    } catch (e) {
      return left(AppError(message: e.toString(), type: AppErrorType.silent));
    }
  }

  Stream<List<ProductType>> watchProductTypes() {
    return _database
        .select(_database.productTypesTable)
        .watch()
        .map((event) => event.map((type) => _mapToProductType(type)).toList());
  }

  Future<Either<AppError, ProductType?>> getProductTypeById(int id) async {
    try {
      TalkerService.log('LocalProductTypeDatasource getProductTypeById: $id');
      final type = await (_database.select(
        _database.productTypesTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (type == null) return right(null);
      return right(_mapToProductType(type));
    } catch (e) {
      return left(AppError(message: e.toString(), type: AppErrorType.silent));
    }
  }

  Future<Either<AppError, int>> createProductType(String name, ProductCategory category) async {
    try {
      final companion = ProductTypesTableCompanion.insert(
        name: name,
        productCategory: category,
        productType: Value(null),
        isCustom: Value(true),
      );

      final id = await _database.into(_database.productTypesTable).insert(companion);
      return right(id);
    } catch (e) {
      return left(AppError(message: e.toString(), type: AppErrorType.silent));
    }
  }

  Future<Either<AppError, void>> updateProductType(ProductType productType) async {
    try {
      final companion = ProductTypesTableCompanion(
        id: Value(productType.id),
        name: Value(productType.name),
        productCategory: Value(productType.category),
        productType: Value(productType.productType),
        isCustom: Value(productType.isCustom),
      );

      await (_database.update(
        _database.productTypesTable,
      )..where((tbl) => tbl.id.equals(productType.id))).write(companion);

      return right(null);
    } catch (e) {
      return left(AppError(message: e.toString(), type: AppErrorType.silent));
    }
  }

  Future<Either<AppError, void>> deleteProductType(int id) async {
    try {
      await (_database.delete(_database.productTypesTable)..where((tbl) => tbl.id.equals(id))).go();

      return right(null);
    } catch (e) {
      return left(AppError(message: e.toString(), type: AppErrorType.silent));
    }
  }

  Future<Either<AppError, List<ProductType>>> getProductTypesByCategory(ProductCategory category) async {
    try {
      TalkerService.log('LocalProductTypeDatasource getProductTypesByCategory: $category');
      final types = await (_database.select(
        _database.productTypesTable,
      )..where((tbl) => tbl.productCategory.equals(category.id))).get();

      return right(types.map((type) => _mapToProductType(type)).toList());
    } catch (e) {
      return left(AppError(message: e.toString(), type: AppErrorType.silent));
    }
  }

  ProductType _mapToProductType(ProductTypesTableData type) {
    return ProductType(
      id: type.id,
      name: type.name,
      category: type.productCategory,
      createdAt: type.createdAt,
      isCustom: type.isCustom,
    );
  }
}
