import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:groceryhelper/domain/entities/product_type.dart';
import 'package:groceryhelper/domain/enums/product_category.dart';
import 'package:groceryhelper/domain/repositories/product_types_repository.dart';
import 'package:groceryhelper/infrastructure/services/talker_service.dart';

part 'category_type_event.dart';
part 'category_type_state.dart';

class CategoryTypeBloc extends Bloc<CategoryTypeEvent, CategoryTypeState> {
  final ProductTypesRepository productTypesRepository;

  StreamSubscription<List<ProductType>>? _userTypesSubscription;
  List<ProductType> _userTypes = [];

  CategoryTypeBloc(ProductCategory category, this.productTypesRepository)
    : super(CategoryTypeState(category: category, types: [])) {
    on<CategoryTypeSelected>(_onCategorySelected);
    on<CategoryTypeInitialized>(_onCategoryTypeInitialized);
    on<CategoryTypeAddCustomType>(_onCategoryTypeAddCustomType);
    on<CategoryTypeUpdateTypes>(_onCategoryTypeUpdateTypes);
  }

  _onCategoryTypeInitialized(CategoryTypeInitialized event, Emitter<CategoryTypeState> emit) {
    _userTypesSubscription = productTypesRepository.watchProductTypes().listen((userTypes) {
      TalkerService.log('Types: $userTypes');
      _userTypes.clear();
      _userTypes.addAll(userTypes);
      add(CategoryTypeUpdateTypes());
    });
  }

  _onCategorySelected(CategoryTypeSelected event, Emitter<CategoryTypeState> emit) {
    TalkerService.log('CategoryTypeSelected: ${event.category}');
    emit(state.copyWith(category: event.category, types: getTypes(event.category)));
  }

  _onCategoryTypeAddCustomType(CategoryTypeAddCustomType event, Emitter<CategoryTypeState> emit) {
    productTypesRepository.createProductType(event.name, event.category).then((value) {
      event.completer.complete(value);
    });
  }

  _onCategoryTypeUpdateTypes(CategoryTypeUpdateTypes event, Emitter<CategoryTypeState> emit) {
    emit(state.copyWith(types: getTypes(state.category)));
  }

  List<ProductType> getTypes(ProductCategory category) {
    return _userTypes.where((type) => type.category == category).toList();
  }

  @override
  Future<void> close() {
    TalkerService.log('CategoryTypeBloc closed');
    _userTypesSubscription?.cancel();
    return super.close();
  }
}
