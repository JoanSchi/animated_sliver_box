// Copyright (C) 2023 Joan Schipper
// 
// This file is part of animated_sliver_box.
// 
// animated_sliver_box is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// animated_sliver_box is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with animated_sliver_box.  If not, see <http://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'animated_sliver_box.dart';
import 'sliver_row_box_model.dart';

enum SliverBoxRequestFeedBack {
  noModel,
  multipleModels,
  individualAnimation,
  groupAnimation,
  accepted,
  error
}

class SliverBoxController<T extends AnimatedSliverBoxModel> {
  final List<T> _models = [];

  SliverBoxController();

  T addModel({
    required T model,
  }) {
    assert(!_models.contains(model));
    _models.add(model);
    return model;
  }

  void removeModel(T model) {
    model.dispose();
    assert(_models.contains(model));
    _models.remove(model);
  }

  bool get isEmpty => _models.isEmpty;

  T? get tryModel => _models.length == 1 ? _models.first : null;

  SliverBoxRequestFeedBack feedBackTryModel(
      SliverBoxRequestFeedBack Function(T model) model) {
    if (_models.isEmpty) {
      return SliverBoxRequestFeedBack.noModel;
    } else if (_models.length != 1) {
      return SliverBoxRequestFeedBack.multipleModels;
    } else {
      return model(_models.single);
    }
  }

  bool get isEmptyOrAdjustable =>
      _models.isEmpty ||
      (_models.length == 1 &&
          _models.single.iterator().fold<bool>(true, (previousValue, element) {
            return previousValue &&
                    element.sliverBoxAction != SliverBoxAction.none ||
                element.individualTransition != 0;
          }));

  @mustCallSuper
  void dispose() {
    for (AnimatedSliverBoxModel model in _models) {
      model.dispose();
    }
  }
}
