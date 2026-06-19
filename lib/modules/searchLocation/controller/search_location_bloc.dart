import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/search_location_model.dart';
import '../repository/search_location_repository.dart';

abstract class SearchLocationEvent {}

class SearchQueryChanged extends SearchLocationEvent {
  final String query;
  final String languageCode;
  SearchQueryChanged(this.query, this.languageCode);
}

class SelectLocation extends SearchLocationEvent {
  final SearchLocationData location;
  SelectLocation(this.location);
}

abstract class SearchLocationState {}

class SearchLocationInitial extends SearchLocationState {}

class SearchLocationLoading extends SearchLocationState {}

class SearchLocationSuccess extends SearchLocationState {
  final List<SearchLocationData> locations;
  SearchLocationSuccess(this.locations);
}

class SearchLocationFailure extends SearchLocationState {
  final String error;
  SearchLocationFailure(this.error);
}

class SearchLocationBloc extends Bloc<SearchLocationEvent, SearchLocationState> {
  final SearchLocationRepository repository;

  SearchLocationBloc(this.repository) : super(SearchLocationInitial()) {
    on<SearchQueryChanged>((event, emit) async {
      if (event.query.isEmpty) {
        emit(SearchLocationInitial());
        return;
      }
      emit(SearchLocationLoading());
      try {
        final response = await repository.searchLocations(event.query, event.languageCode);
        emit(SearchLocationSuccess(response.data ?? []));
      } catch (e) {
        emit(SearchLocationFailure(e.toString()));
      }
    });
  }
}
