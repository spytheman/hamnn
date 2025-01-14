// explore_test.v
module explore

import tools
// import os


fn test_explore_cross() {
	mut results := []tools.VerifyResult{}
	mut opts := tools.Options{
		verbose_flag: false
		number_of_attributes: [1, 4]
		bins: [2, 12]
		show_flag: false
		concurrency_flag: true
		uniform_bins: true
		datafile_path: 'datasets/iris.tab'
	}
	mut ds := tools.load_file(opts.datafile_path)
	results = explore(ds, opts)
	// println(results)
	assert results[0].correct_count == 100
	assert results[0].misses_count == 50
	assert results[0].wrong_count == 50
	assert results[0].total_count == 150

	opts.uniform_bins = false
	results = explore(ds, opts)
	assert results[results.len - 1].correct_count == 141
	assert results[results.len - 1].misses_count == 9
	assert results[results.len - 1].wrong_count == 9
	assert results[results.len - 1].total_count == 150

	opts.folds = 10
	opts.number_of_attributes = [27, 29]
	opts.bins = [20, 22]
	opts.weighting_flag = true
	opts.datafile_path = 'datasets/anneal.tab'
	opts.uniform_bins = true
	ds = tools.load_file(opts.datafile_path)
	results = explore(ds, opts)
	assert results[1].correct_count == 875
	assert results[1].misses_count == 23
	assert results[1].wrong_count == 23
	assert results[1].total_count == 898

	opts.uniform_bins = false
	results = explore(ds, opts)
	assert results[1].correct_count == 878
	assert results[1].misses_count == 20
	assert results[1].wrong_count == 20
	assert results[1].total_count == 898
}


fn test_explore_verify() {
	mut opts := tools.Options{
		concurrency_flag: true
		weighting_flag: true
		testfile_path: 'datasets/bcw174test'
		datafile_path: 'datasets/bcw350train'
	}
	mut ds := tools.load_file(opts.datafile_path)
	mut results := explore(ds, opts)
	assert results[7].correct_count == 170
	assert results[7].wrong_count == 4
}


// fn test_explore_save() ? {
// 	mut results := []tools.VerifyResult{}
// 	mut opts := tools.Options{
// 		verbose_flag: false
// 		number_of_attributes: [1, 4]
// 		bins: [2, 12]
// 		show_flag: false
// 		concurrency_flag: true
// 		uniform_bins: true
// 		datafile_path: 'datasets/iris.tab'
// 		outputfile_path: 'testfile'
// 		command: 'explore'
// 	}
// 	// mut ds := tools.load_file(opts.datafile_path)
// 	// results = explore(ds, opts)

// 	mut f := os.open_file(opts.outputfile_path, 'r') or { panic(err.msg) }
// 	mut testopts := tools.Options{}
// 	f.read_struct(mut testopts) or { panic(err.msg) }
// 	mut testresults := []tools.VerifyResult{}
// 	f.read_struct(mut testresults) or { panic(err.msg) }
// 	f.close()
// 	println(testopts)
// 	println(testresults)
// 	assert testopts == opts
// 	assert results == testresults
// }
