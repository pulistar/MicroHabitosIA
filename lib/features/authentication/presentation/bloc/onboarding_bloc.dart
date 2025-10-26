import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../domain/usecases/get_onboarding_items.dart';
import '../../../../core/usecases/usecase.dart';

// Eventos
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class LoadOnboardingItemsEvent extends OnboardingEvent {}

// Estados
abstract class OnboardingState extends Equatable {
  const OnboardingState();
  
  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingItem> items;

  const OnboardingLoaded({required this.items});

  @override
  List<Object> get props => [items];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingItemsUseCase getOnboardingItemsUseCase;

  OnboardingBloc({required this.getOnboardingItemsUseCase}) : super(OnboardingInitial()) {
    on<LoadOnboardingItemsEvent>(_onLoadOnboardingItems);
  }

  void _onLoadOnboardingItems(
    LoadOnboardingItemsEvent event, 
    Emitter<OnboardingState> emit
  ) async {
    emit(OnboardingLoading());

    final result = await getOnboardingItemsUseCase(NoParams());

    result.fold(
      (failure) => emit(OnboardingError(message: failure.message)),
      (items) => emit(OnboardingLoaded(items: items))
    );
  }
}
