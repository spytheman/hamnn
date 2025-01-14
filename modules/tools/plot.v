module tools

// import arrays
import math
import vsl.plot

struct RankTrace {
mut:
	label              string
	rank_values        []f64
	maximum_rank_value f32
	hover_text         []string
}

// plot_rank ranked_atts generates a scatterplot of the rank values
// for continuous attributes, as a function of the number of bins.
pub fn plot_rank(ranked_atts []RankedAttribute, opts Options) {
	mut traces := []RankTrace{}
	mut plt := plot.new_plot()
	mut x := []f64{}
	for i in opts.bins[0] .. opts.bins[1] + 1 {
		x << i
	}
	for attr in ranked_atts.filter(it.inferred_attribute_type == 'C') {
		traces << RankTrace{
			label: '$attr.attribute_name ${max(attr.rank_value_array):5.2f}'
			rank_values: attr.rank_value_array.map(f64(it)).reverse()
			maximum_rank_value: max(attr.rank_value_array)
			// the tooltip for each point shows the attribute name
			hover_text: ['$attr.attribute_name'].repeat(opts.bins[1] + 1)
		}
	}
	// sort in descending order of maximum_rank_value
	traces.sort(a.maximum_rank_value > b.maximum_rank_value)

	mut attributes := []string{}
	for value in traces {
		attributes << value.hover_text
		plt.add_trace(
			trace_type: .scatter
			x: x
			y: value.rank_values
			text: value.hover_text
			mode: 'lines+markers'
			name: value.label
			hovertemplate: 'attribute: %{text}<br>bins: %{x}<br>rank: %{y}'
		)
	}
	plt.set_layout(
		title: 'Rank Values for Continuous Attributes for $opts.datafile_path'
		autosize: false
		width: 800
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Number of bins'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Rank Value'
			}
			range: [0.0, 100]
		}
	)
	plt.show() or { panic(err) }
}

struct ExploreTrace {
mut:
	label           string
	percents        []f64
	max_percents    f64
	attributes_used []f64
	bin_range       []string
}

// plot_explore generates a scatterplot for the results of
// an explore on a dataset
pub fn plot_explore(results []VerifyResult, opts Options) {
	mut plt := plot.new_plot()
	mut traces := []ExploreTrace{}
	mut x := []f64{}
	mut y := []f64{}
	mut bin_values := []string{}
	mut y_value := 1.0
	mut percents := []f64{}
	mut max_percents := 0.0
	for result in results {
		y_value = (f32(result.correct_count) * 100 / result.total_count)
		x << f64(result.attributes_used)
		y << y_value
		// create strings that can be used for filtering
		if result.bin_values.len == 1 {
			bin_values << '${result.bin_values[0]} bins'
		} else {
			bin_values << 'bins ${result.bin_values[0]} - ${result.bin_values[1]}'
		}
	}
	// get the unique bin_values, each one will generate a separate trace
	for key, _ in string_element_counts(bin_values) {
		percents = filter(key, bin_values, y).map((math.round(it * 100)) / 100)
		max_percents = max(percents)
		traces << ExploreTrace{
			label: '$key ${max(percents):5.2f}'
			percents: percents
			max_percents: max_percents
			attributes_used: filter(key, bin_values, x)
			bin_range: ['$key']
		}
	}
	// sort the traces according to the maximum value of percents
	traces.sort(a.max_percents > b.max_percents)

	for value in traces {
		plt.add_trace(
			trace_type: .scatter
			x: value.attributes_used
			y: value.percents
			text: value.bin_range.repeat(value.percents.len)
			mode: 'lines+markers'
			name: value.label
			hovertemplate: '%{text}<br>attributes: %{x}<br>accuracy: %{y}%'
		)
	}
	annotation := plot.Annotation{
		x: (max(x) + min(x))/2
		y: 5
		text: 'Hover your cursor over a marker to view details.'
		align: 'center'
	}
	plt.set_layout(
		title: 'Accuracy (%) by Attributes Used for $opts.datafile_path'
		width: 800
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'Number of Attributes Used'
			}
		}
		annotations: [annotation]
		autosize: false
	)
	plt.show() or { panic(err) }
}

struct ROCResult {
	sensitivity           f64
	one_minus_specificity f64
	bin_range             string
	attributes_used       string
}

struct ROCTrace {
mut:
	x_coordinates   []f64
	y_coordinates   []f64
	area_under_curve f64
	// curve_series_variable string 
	curve_series_variable_values string 
	// curve_variable string 
	curve_variable_values []string
}

// plot_roc plot receiver operating characteristic curves
pub fn plot_roc(results []VerifyResult, opts Options) {
	mut roc_results := []ROCResult{}
	mut plt := plot.new_plot()
	mut traces := []ROCTrace{}
	mut x_coordinates := []f64{}
	mut y_coordinates := []f64{}
	mut bin_range_values := []string{}
	mut attributes_used_values := []string{}
	mut bin_range := ''
	mut pos_class := results[0].pos_neg_classes[0]
	mut neg_class := results[0].pos_neg_classes[1]

	// first, we'll do a series of curves, one per bin range, thus
	// with the number of attributes varying

	for result in results {
		// create strings that can be used for filtering
		if result.bin_values.len == 1 {
			bin_range = '${result.bin_values[0]} bins'
		} else {
			bin_range = 'bins ${result.bin_values[0]} - ${result.bin_values[1]}'
		}
		roc_results << ROCResult{
			sensitivity: result.class_table[pos_class].correct_inferences / f64(
				result.class_table[pos_class].correct_inferences +
				result.class_table[neg_class].missed_inferences)
			one_minus_specificity: 1.0 - (result.class_table[neg_class].correct_inferences / f64(
				result.class_table[neg_class].correct_inferences +
				result.class_table[pos_class].missed_inferences))
			bin_range: bin_range
			attributes_used: '$result.attributes_used'
		}
	}
	// println('roc_results: $roc_results')
	// sort on the x axis value, ie one_minus_specificity
	roc_results.sort(a.one_minus_specificity < b.one_minus_specificity)
	// get the unique bin_range values, each one will generate a separate trace
	for roc_result in roc_results {
		bin_range_values << roc_result.bin_range
		attributes_used_values << roc_result.attributes_used
		x_coordinates << roc_result.one_minus_specificity
		y_coordinates << roc_result.sensitivity
	}
	for key, _ in string_element_counts(bin_range_values) {
		traces << ROCTrace{
			curve_series_variable_values: '$key'
			x_coordinates: filter(key, bin_range_values, x_coordinates)
			y_coordinates: filter(key, bin_range_values, y_coordinates)
			curve_variable_values: filter(key, bin_range_values, attributes_used_values)
		}
	}
	traces = massage_roc_traces(mut traces)
	make_roc_plot_traces(traces, mut plt, 'attributes used')
	annotation := plot.Annotation{
		x: 0.5
		y: -0.05
		text: 'Hover your cursor over a marker to view details.'
		align: 'center'
	}
	make_roc_plot_layout(mut plt, 'Attributes Used', [annotation])
	
	plt.show() or { panic(err) }

	// now a series of curves, one per attributes_used value
	plt = plot.new_plot()
	traces.clear()
	for key, _ in string_element_counts(attributes_used_values) {
		traces << ROCTrace{
			curve_series_variable_values: '$key'
			x_coordinates: filter(key, attributes_used_values, x_coordinates)
			y_coordinates: filter(key, attributes_used_values, y_coordinates)
			curve_variable_values: filter(key, attributes_used_values, bin_range_values)
		}
	}
	traces = massage_roc_traces(mut traces)
	make_roc_plot_traces(traces, mut plt, 'binning')
	make_roc_plot_layout(mut plt, 'Attributes Used', [annotation])

	plt.show() or { panic(err) }
}


// filter takes two coordinated arrays. It filters array b
// to include only elements whose corresponding element
// in array a is equal to the match_value.
fn filter<T>(match_value string, a []string, b []T) []T {
	mut result := []T{}
	for i, value in a {
		if match_value == value {
			result << b[i]
		}
	}
	return result
}

// area_under_curve calculates area under the curve 
// as the areas of a series of rectangles and triangles
fn area_under_curve(x []f64, y []f64) f64 {
	mut area := 0.0
	mut b := 0.0
	if x.len != 0 {
	for i in 0 .. (x.len - 1) {
		b = (x[i + 1] - x[i])
		area += b * y[i] + 0.5 * b * (y[i + 1] - y[i])
	}
}
	return area
}

// massage_roc_traces appends 0. and 1. to the beginning and end of
// the x and y arrays and 'none' to the curve_variable_values array;
// it then calculates areas under the curve (AUC), and sorts the traces
// in descending order of AUC
fn massage_roc_traces(mut traces []ROCTrace) []ROCTrace {
	for mut trace in traces {
		trace.x_coordinates.prepend(0.0)
		trace.y_coordinates.prepend(0.0)
		trace.curve_variable_values.prepend('none')
		trace.x_coordinates << 1.0
		trace.y_coordinates << 1.0
		trace.curve_variable_values << 'none'
		trace.area_under_curve = area_under_curve(trace.x_coordinates, trace.y_coordinates)
	}
	traces.sort(a.area_under_curve > b.area_under_curve)
	return traces
}
// make_roc_plot_traces 
fn make_roc_plot_traces(traces []ROCTrace, mut plt plot.Plot, hover_variable string) {
	for trace in traces {
		plt.add_trace(
			trace_type: .scatter
			x: trace.x_coordinates
			y: trace.y_coordinates
			mode: 'lines+markers'
			name: '$trace.curve_series_variable_values (AUC=${trace.area_under_curve:3.2})'
			text: trace.curve_variable_values
			hovertemplate: '$hover_variable: %{text}<br>sensitivity: %{x}<br>one minus specificity: %{y}%'
		)
	}
}

// make_roc_plot_layout 
fn make_roc_plot_layout(mut plt plot.Plot, curve_series string, annotations []plot.Annotation) {
	plt.set_layout(
		title: 'Receiver Operating Characteristic Curves by $curve_series'
		width: 800
		height: 800
		xaxis: plot.Axis{
			title: plot.AxisTitle{
				text: '1 - specificity'
			}
		}
		yaxis: plot.Axis{
			title: plot.AxisTitle{
				text: 'sensitivity'
			}
		}
		annotations: annotations
	)
}
