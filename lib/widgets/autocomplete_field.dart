import 'package:flutter/material.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';

import '../utils/color.dart';

class CustomAutocompleteSearch1 extends StatefulWidget {
  final String? hint;
  List<String>? suggestions;
  final Function? onSelected;
  final Border? border;
  final Function? filter;
  // final int? minLines;
  // final int? maxLines;
  // final int? maxLength;
  final bool? hideSuggestionsOnCreate;
  final double? tileMinHeight;
  final double? tileMaxHeight;
  final TextEditingController? controller;
  final Function? onChange;
  final Function? onTap;
  final bool? enabled;

  CustomAutocompleteSearch1(
      {this.hint,
        this.suggestions,
        this.onSelected,
        // this.minLines,
        // this.maxLength,
        this.border,
        this.enabled,
        // this.maxLines = 1,
        this.filter,
        this.hideSuggestionsOnCreate,
        this.tileMinHeight,
        this.tileMaxHeight,
        this.controller,
        this.onChange,
        this.onTap})
      : super();

  @override
  _CustomAutocompleteSearch1State createState() =>
      _CustomAutocompleteSearch1State();
}

class _CustomAutocompleteSearch1State extends State<CustomAutocompleteSearch1> {
  List<String> _tmpSuggestions = []; // Will be shown to user
  List<String> _selectedOptions = [];

  double _suggestionsHeight = 1;
  String _fieldText = "";

  @override
  void initState() {
    super.initState();
    if (widget.suggestions == null) {
      widget.suggestions = [
        "No suggestion list entered",
        "Pass List of strings to value of \'suggestions\' key",
        "suggestions: List<String>",
        "Foo",
        "Bar",
        "Abc",
        "abcdefghijklmnopqrstuvwxyzåäö",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ",
        "I am very long string. If you do not want the user to see the whole long text, You must use tileMaxHeight property. Normally tileMaxHeight is double.infinity. You can customize it. If you want it to be 200 just use tileMaxHeight:200. If you want to make sure everything fits, you could use double.infinity. Min height is also customizable, default value is 50. Happy codin' fo you!",
        "abcdefghijklmnopqrstuvwxyzåäö"
      ];
    }

    //_textChanged(_fieldText);

    /*if (widget.hideSuggestionsOnCreate == null ||
        widget.hideSuggestionsOnCreate == true) {*/
    _tmpSuggestions = [];
    _suggestionsHeight = 1.0;
    //}

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      child: Column(
        children: <Widget>[
          Focus(
            onFocusChange: _handleFocusChanged,
            child: widget.hint != "Mobile Number"
                ? TextField(
              onChanged: _textChanged,
              controller: widget.controller,
              /*decoration: new InputDecoration(
                hintText: widget.hint ?? 'Insert text here',
              ),*/
              onTap: () {
                int suggestionsLength = _tmpSuggestions.length;
                if (widget.controller!.text == "" && widget.onTap != null)
                  widget.onTap!();
              },
              style: TextStyle(color: black),
              keyboardType: widget.hint == "Mobile Number"
                  ? TextInputType.phone
                  : TextInputType.text,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: black),
                ),
                hintStyle: TextStyle(color: darkgrey),
                labelStyle: TextStyle(color: darkgrey),
                labelText: widget.hint ?? "Insert text here",
                hintText: "",
                // Concatenate selected options with the text typed by the user
                // and display it as the text of the TextField
                // This assumes _selectedOptions is a List<String> containing selected options
                // and widget.controller.text is the text typed by the user
                // You can adjust this logic based on your specific requirements
                // For example, you may want to format the displayed text differently
                // or include a separator between the selected options and the user's text
                // Here, we're simply joining them with a space
                // You can adjust this as needed
                // If _selectedOptions is empty, only the user's text will be displayed
                // If _selectedOptions is not empty, both selected options and user's text will be displayed
                // prefixText: _selectedOptions.isNotEmpty
                //     ? "${_selectedOptions.join(", ")} "
                //     : null,
              ),
            )
                : TextField(
              onChanged: _textChanged,
              controller: widget.controller,
              // maxLines: 5,
              // minLines: 5,
              // maxLength: 500,
              onTap: () {
                int suggestionsLength = _tmpSuggestions.length;
                if (widget.controller!.text == "" && widget.onTap != null)
                  widget.onTap!();
              },
              style: TextStyle(color: black),
              keyboardType: widget.hint == "Mobile Number"
                  ? TextInputType.phone
                  : TextInputType.text,
              decoration: InputDecoration(
                counterText: "",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: black),
                ),
                hintStyle: TextStyle(color: darkgrey),
                labelStyle: TextStyle(color: darkgrey),
                labelText: widget.hint ?? "Insert text here",
                hintText: "",
              ),
            ),
          ),
          Wrap(
            children: _selectedOptions
                .map((option) => Chip(
              label: Text(option),
              onDeleted: () {
                // Remove the option when it's deleted from chips
                setState(() {
                  _selectedOptions.remove(option);
                });
              },
            ))
                .toList(),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 1,
              maxHeight: _suggestionsHeight,
              maxWidth: double.infinity,
              minWidth: double.infinity,
            ),
            child: Container(
                decoration: BoxDecoration(
                    border: widget.border ??
                        Border(
                          left:
                          BorderSide(width: 1.0, color: Color(0xFFbfbfbf)),
                          right:
                          BorderSide(width: 1.0, color: Color(0xFFbfbfbf)),
                          bottom:
                          BorderSide(width: 1.0, color: Color(0xFFbfbfbf)),
                        )),
                child: Scrollbar(
                  child: ListView.builder(
                    itemBuilder: (context, position) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: widget.tileMinHeight ??
                              SizeConfig.blockSizeVertical !* 7,
                          maxHeight: SizeConfig.blockSizeVertical !* 7,
                          maxWidth: double.infinity,
                          minWidth: double.infinity,
                        ),
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              String selectedSuggestion = _tmpSuggestions[position];
                              _handleSuggestionPress(selectedSuggestion);
                              widget.controller!.text = selectedSuggestion;
                              // _suggestionsHeight = 1;
                              setState(() {});
                            },
                            // onTap: () {
                            //   _handleSuggestionPress(_tmpSuggestions[position]);
                            //   widget.controller!.text =
                            //       _tmpSuggestions[position];
                            //   _suggestionsHeight = 1;
                            //   setState(() {});
                            // },
                            title: Text(
                              _tmpSuggestions[position],
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _tmpSuggestions.length,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void _textChanged(String text) {
    _fieldText = text;

    _tmpSuggestions.clear();

    // Loop new list and add valid suggestions to the original list.
    if (widget.controller!.text != "") {
      for (String suggestion in widget.suggestions!) {
        if (widget.filter == null) {
          // Go with the default filtering
          if (_isValid(suggestion, text)) {
            _tmpSuggestions.add(suggestion);
          }
        } else {
          // Use custom filtering
          if (widget.filter!(suggestion, text)) {
            _tmpSuggestions.add(suggestion);
          }
        }
      }
    }
    setState(() {});

    int suggestionsLength = _tmpSuggestions.length;
    if (suggestionsLength == 0) {
      _suggestionsHeight = 1;
    } else {
      _suggestionsHeight = SizeConfig.blockSizeVertical! * 18;
    }
  }
  // void _textChanged(String text) {
  //   _fieldText = text;
  //
  //   _tmpSuggestions.clear();
  //
  //   // Loop new list and add valid suggestions to original list.
  //   if (widget.controller!.text != "") {
  //     for (String suggestion in widget.suggestions!) {
  //       if (widget.filter == null) {
  //         // Go with the default filtering
  //         if (_isValid(suggestion, text)) {
  //           _tmpSuggestions.add(suggestion);
  //         }
  //       } else {
  //         // Use custom filtering
  //         if (widget.filter!(suggestion, text)) {
  //           _tmpSuggestions.add(suggestion);
  //         }
  //       }
  //     }
  //   }
  //   setState(() {});
  //
  //   int suggestionsLength = _tmpSuggestions.length;
  //   if (suggestionsLength == 0) {
  //     _suggestionsHeight = 1;
  //     return;
  //   } else {
  //     _suggestionsHeight = SizeConfig.blockSizeVertical !* 18;
  //   }
  //
  //   /*else if (suggestionsLength > 4) {
  //     _suggestionsHeight = 250.0;
  //   } else {
  //     _suggestionsHeight = suggestionsLength.toDouble() * 60 + 10;
  //   }*/
  // }

  bool _isValid(String suggestion, String characters) {
    return suggestion.toLowerCase().contains(characters.toLowerCase());
  }

  void _handleFocusChanged(bool focus) {
    if (focus) {
      _textChanged(_fieldText);
    } else {
      setState(() {
        _suggestionsHeight = 1;
      });
    }
  }

  void _handleSuggestionPress(String selected) {
    if (_selectedOptions.contains(selected)) {
      // If the option is already selected, remove it
      _selectedOptions.remove(selected);
    } else {
      // If the option is not selected, add it
      _selectedOptions.add(selected);
    }

    // Get the current text in the controller
    String currentText = widget.controller!.text;

    // Concatenate selected suggestions with the existing text in the controller
    String mergedText = _selectedOptions.join(", ");
    if (currentText.isNotEmpty) {
      mergedText = "$currentText, $mergedText";
    }

    // Update the controller's text
    widget.controller!.text = mergedText;

    // Update the UI
    setState(() {});
  }
}
