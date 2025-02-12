module tools

import os
import strconv
import math
// import arrays

// const integer_range_for_discrete = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

// load_file returns a struct containing the datafile's information
pub fn load_file(path string) Dataset {
	mut ds := Dataset{}
	if file_type(path) == 'orange_newer' {
		ds = load_orange_newer_file(path)
	} else {
		ds = load_orange_older_file(path)
	}
	return ds
}

// load_orange_older_file loads from a file into a Dataset struct
pub fn load_orange_older_file(path string) Dataset {
	content := os.read_lines(path.trim_space()) or { panic('failed to open $path') }
	mut ds := Dataset{
		path: path
		attribute_names: extract_words(content[0])
		attribute_types: extract_words(content[1])
		attribute_flags: extract_words(content[2])
		data: transpose(content[3..].map(extract_words(it)))
	}
	ds.inferred_attribute_types = infer_attribute_types_older(ds)
	ds.Class = set_class_struct(ds)

	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	return ds
}

// infer_attribute_types_older gets inferred attribute types for orange-older files
// returns an array to plug into the Dataset struct
/*
For orange-older:
in the second line (ds.attribute_types):
  	'd' or 'discrete' or a list of values: denotes a discrete attribute
  	'c' or 'continuous': denotes a continuous attribute
  	'string' denotes a string variable, which we ignore
  	'basket': these are continuous-valued meta attributes; ignore
  	it may also contain a string of values separated by spaces. Use these
  	as the values for a discrete attribute.
  the third line (ds.attribute_flags) contains optional flags:
  	'i' or 'ignore'
  	'c' or 'class': there can only be one class attribute. If none is found,
  	 use the last attribute as the class attribute.
  	'm' or 'meta': meta attribute, eg weighting information; ignore
  	'-dc' followed by a value: indicates how a don't care is represented.
*/
fn infer_attribute_types_older(ds Dataset) []string {
	mut inferred_attribute_types := []string{}
	mut attr_type := ''
	mut attr_flag := ''
	mut inferred := ''
	for i in 0 .. ds.attribute_names.len {
		attr_type = ds.attribute_types[i]
		attr_flag = ds.attribute_flags[i]
		if attr_flag in ['c', 'class'] {
			inferred = 'c'
		} else if attr_type in ['d', 'discrete'] {
			inferred = 'D'
		} else if attr_type in ['c', 'continuous'] {
			inferred = 'C'
		} else if attr_type in ['string', 'basket'] || attr_flag in ['i', 'ignore'] {
			inferred = 'i'
		}
		// if the entry contains a list of items separated by spaces
		else if attr_type.contains(' ') {
			inferred = 'D'
		} else if attr_type == '' && attr_flag == '' {
			inferred = infer_type_from_data(ds.data[i])
		} else {
			panic('unrecognized attribute type "$attr_type" for attribute "${ds.attribute_names[i]}"')
		}
		inferred_attribute_types << inferred
	}
	return inferred_attribute_types
}

// load_orange_newer_file loads from an orange-newer file into a Dataset struct
pub fn load_orange_newer_file(path string) Dataset {
	content := os.read_lines(path.trim_space()) or { panic('failed to open $path') }
	attribute_words := extract_words(content[0])
	types_attributes := attribute_words.map(extract_types(it))
	mut ds := Dataset{
		path: path
		attribute_names: types_attributes.map(it[1])
		attribute_types: types_attributes.map(it[0])
		data: transpose(content[1..].map(extract_words(it)))
	}
	ds.inferred_attribute_types = infer_attribute_types_newer(ds)
	ds.Class = set_class_struct(ds)
	ds.useful_continuous_attributes = get_useful_continuous_attributes(ds)
	ds.useful_discrete_attributes = get_useful_discrete_attributes(ds)
	return ds
}

// infer_attribute_types_newer gets inferred attribute types for orange-older files
// returns an array to plug into the Dataset struct
/*
The existing attribute type codes are, for orange-newer:
Attribute names in the column header can be preceded with a label followed by a hash. Use c for class and m for meta attribute, i to ignore a column, w for weights column, and C, D, T, S for continuous, discrete, time, and string attribute types. Examples: C#mph, mS#name, i#dummy.
If no prefix, treat numbers as continuous, otherwise discrete
['i', 'mS', 'D', 'cD', 'C', 'm', 'iB', 'T', 'S', ''] should code as:
['i', 'i', 'D', 'c', 'C', 'i', 'i', 'i', 'i', 'C']
*/
fn infer_attribute_types_newer(ds Dataset) []string {
	mut inferred_attribute_types := []string{}
	mut attr_type := ''
	mut inferred := ''
	for i in 0 .. ds.attribute_names.len {
		attr_type = ds.attribute_types[i]
		if attr_type in ['C', 'D', 'c', 'i'] {
			inferred = attr_type
		} else if attr_type.contains('c') {
			inferred = 'c'
		} else if attr_type in ['m', 'w', 'S', 'T'] {
			inferred = 'i'
		} else if attr_type == '' {
			inferred = infer_type_from_data(ds.data[i])
		} else {
			panic('unrecognized attribute type "$attr_type" for attribute "${ds.attribute_names[i]}"')
		}
		inferred_attribute_types << inferred
	}
	return inferred_attribute_types
}

// infer_type_from_data
fn infer_type_from_data(values []string) string {
	// if no data, 'i'
	if values == [] {
		return 'i'
	}
	// if all the elements are identical, then the attribute is useless, so 'i'
	if string_element_counts(values).len == 1 {
		return 'i'
	}
	// else, examine individual data elements
	mut inferred_attribute_type := 'i'
	for element in values {
		// skip over missing data
		if element in missings {
			continue
		}
		// if it could be a float...
		else if element.contains('.') {
			// rule out non-numeric strings
			if strconv.atof_quick(element) == 0e+00 {
				inferred_attribute_type = 'D'
				break
			} else {
				inferred_attribute_type = 'C'
				break
			}
		}
		// if an integer, test that all the values are within the range
		// for discrete attributes (from a constant)
		// TODO: use the lists of values from the second line of orange-older files
		else if element.int() in integer_range_for_discrete {
			inferred_attribute_type = 'D'
			continue
		} else {
			inferred_attribute_type = 'C'
			break
		}
	}
	return inferred_attribute_type
}

// get_useful_continuous_attributes
pub fn get_useful_continuous_attributes(ds Dataset) map[int][]f32 {
	// initialize the values of the result to -max_f32, to indicate missing values
	// mut min_value := f32(0.)
	// mut max_value := f32{0.}
	mut cont_att := map[int][]f32{}
	for i in 0 .. ds.attribute_names.len {
		if ds.inferred_attribute_types[i] == 'C' && string_element_counts(ds.data[i]).len != 1 {
			nums := ds.data[i].map(fn (w string) f32 {
				if w in missings { return -math.max_f32
				 } else { return f32(strconv.atof_quick(w))
				 }
			})
			cont_att[i] = nums
		}
	}
	return cont_att
}

// get_useful_discrete_attributes
pub fn get_useful_discrete_attributes(ds Dataset) map[int][]string {
	mut disc_att := map[int][]string{}
	for i in 0 .. ds.attribute_names.len {
		if ds.inferred_attribute_types[i] == 'D' && string_element_counts(ds.data[i]).len != 1 {
			disc_att[i] = ds.data[i]
		}
	}
	return disc_att
}

// set_class_struct
fn set_class_struct(ds Dataset) Class {
	i := identify_class_attribute(ds.inferred_attribute_types)
	mut cl := Class{
		class_name: ds.attribute_names[i]
		class_values: ds.data[i]
		class_counts: string_element_counts(ds.data[i])
	}
	return cl
}

fn extract_words(line string) []string {
	mut splitted := []string{}
	for tab_splitted in line.split('\t') {
		splitted << tab_splitted
	}
	// println('splitted: $splitted')
	return splitted
}

fn extract_types(word string) []string {
	type_att := word.split('#')
	if type_att.len == 1 {
		return ['', type_att[0]]
	} else {
		return type_att
	}
}

// identify_class_attribute returns the index for the class attribute
fn identify_class_attribute(inferred_attribute_types []string) int {
	mut i := 0
	for i <= inferred_attribute_types.len {
		if inferred_attribute_types[i] == 'c' {
			break
		}
		i++
	}
	return i
}
