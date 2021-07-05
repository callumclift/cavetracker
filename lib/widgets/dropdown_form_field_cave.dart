import 'package:caving_app/models/cave_model.dart';
import 'package:flutter/material.dart';

class DropdownFormFieldCave extends StatefulWidget {
  final String hint;
  final Cave value;
  final List<Cave> items;
  final Function onChanged;
  final Function validator;
  final Function onSaved;
  final Cave initialValue;
  final bool expanded;

  DropdownFormFieldCave({
    @required this.hint,
    @required this.value,
    @required this.items,
    @required this.onChanged,
    @required this.validator,
    @required this.initialValue,
    @required this.onSaved,
    @required this.expanded
  });

  @override
  State<StatefulWidget> createState() {
    return _DropdownFormFieldCave();
  }
}

class _DropdownFormFieldCave extends State<DropdownFormFieldCave> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: widget.initialValue,
      onSaved: (val) => widget.onSaved,
      validator: widget.validator,
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: widget.hint,
            errorText: state.hasError ? state.errorText : null,
          ),
          isEmpty: widget.value == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Cave>(
              isExpanded: true,
              value: widget.value,
              isDense: widget.expanded ? false : true,
              onChanged: (Cave newValue) {
                state.didChange(newValue);
                widget.onChanged(newValue);
              },
              items: widget.items.map((Cave value) {
                return DropdownMenuItem<Cave>(
                  value: value,
                  child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Container(child: Flexible(child: Text(value.name)))],),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
