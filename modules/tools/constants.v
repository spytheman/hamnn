// constants.v

module tools

pub const (
	missings                   = ['?', '']

	integer_range_for_discrete = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

	hamnn_help                 = "

hamnn runs a machine learning algorithm on a dataset file.
help, -h, --help to display this usage information.
For help with any of the commands below, enter the command followed by
  -h or --help, eg 'v run hamnn.v make --help'.
Usage:
Specify the file's path as the last command line argument, 
  eg, v run hamnn.v analyze datasets/iris.tab
Commands:
analyze:   print information about the dataset to the console;
cross:     performs a cross-validation on a dataset;
explore:   carry out a series of verification experiments over a range of
           parameter settings, in order to find optimal values for classifier
           parameters.
help:      show this usage information;
make:      create a classifier from a dataset;
orange:    print an explanation of Orange file formats to the console;
query:     using a classifier, create an instance using an interactive
           dialogue and classify that instance;
rank:      rank order the dataset's attributes in terms of their
           power in separating classes;
validate:  as for verify, but using an unlabeled second dataset. Outputs 
           inferred classes for the second dataset; TODO
verify:    use a classifier and a second labeled dataset to verify how well
           the classifier performs in classifying the second dataset's 
           instances;
			"

	analyze_help = '
"analyze" displays on the console information about a 
datafile\'s type, the attributes, and the class attribute. The following
tables are output: 
1. a list of attributes, their types, the unique values, and a count of
missing values;
2. a table with counts for each type of attribute;
3. a list of discrete attributes useful for training a classifier;
4. a list of continuous attributes useful for training a classifier;
5. a breakdown of the class attribute, showing counts for each class. 

Usage: v run hamnn.v analyze datasets/iris.tab

Options:
  -h, --help displays this message.
		'

	rank_help = '"rank" rank orders a dataset\'s attributes in terms of ability 
to distinguish between classes; it takes into account class prevalences.

Usage: v run hamnn.v rank -s datasets/anneal.tab

Options: 
  -b --bins, eg, "3,6" specifies the lower and upper limits for the number 
      of slices or bins for continuous attributes;
  -x --exclude, exclude missing values from rank value calculations;
  -s --show, output to the console a list ordered by rank value;
  -g --graph, produce a graph showing rank values vs number of bins. TODO
	'

	make_help = '
"make" creates a classifier from the datafile given as the last argument.
Returns a classifier struct.

Usage: v run hamnn.v make -v datasets/iris.tab

Options:
  -a --attributes, the number of attributes (picked from the list of 
      ranked attributes) to be used in training the classifier
  -b --bins, eg, "3,6" specifies the lower and upper limits for the number
      of slices or bins for continuous attributes;
  -j --json, followed by a file path for a file where a json serialization
      of the classifier is to be stored; (TODO)
  -s --show, output to the console information about the classifier;
  -v --verbose, output debugging information to the console;
  -x --exclude, exclude missing values from rank value calculations;
	'

	classify_help = '
"classify" classifies one or more unlabeled instances, using a classifier
created by "make". It returns a list of inferred classes.

Options: 
  -w --weight, weight the number of nearest neighbor counts by class 
      prevalences.
	'

	query_help = '
"query" takes a classifier created by make(), and interactively asks the user
to input (at the console) values for each attribute included in the classifier.
After the last entry, it classifies the new instance and returns its inferred
class.
In addition to the options below, the options for the "make" command are also
applicable.

Options:
	-v --verbose, show additional information for each query, and additional 
	statistics for the classification.
	-w --weight, weight the number of nearest neighbor counts by class prevalences.
	'

	orange_help = "
NEWER ORANGE FORMAT:
  Prefixed attributes contain a one- or two-lettered prefix, followed by '#'
  and the attribute name. The first letter of the prefix can be:
  	'm' for meta-attributes
  	'i' to ignore the attribute
  	'c' to define the class attribute

  the second letter of the prefix can be:
  	'D' for discrete
  	'C' for continuous
  	'S' for string
  	'B' for basket
  if there are no prefixes for an attribute (ie just the attribute name)
  then the attribute will be treated as discrete, unless the actual values
  are numbers, in which case it will be treated as continuous.

  OLDER ORANGE FORMAT:
  the information about variable type, etc is contained in two lines:
  	in the second line:
  	'd' or 'discrete' or a list of values: denotes a discrete attribute
  	'c' or 'continuous': denotes a continuous attribute
  	'string' denotes a string variable, which we ignore
  	'basket': these are continuous-valued meta attributes; ignore
  	it may also contain a string of values separated by spaces. Use these
  	as the values for a discrete attribute.
  the third line contains optional flags:
  	'i' or 'ignore'
  	'c' or 'class': there can only be one class attribute. If none is found,
  	 use the last attribute as the class attribute.
  	'm' or 'meta': meta attribute, eg weighting information; ignore
  	'-dc' followed by a value: indicates how a don't care is represented.
	"

	verify_help = '
"verify" takes a classifier created by make, and another datafile
to be used as a verification dataset. The parameters for which attributes to 
use, the list of permissible attribute values for discrete attributes, and the 
binning information for continuous attributes is copied from the 
classification dataset. Each instance in the verification
dataset is classified, and the inferred classes are compared to the labeled
classes to provide accuracy and other statistics.

Options:
	In addition to the options below, the options for "make" apply to 
	both the classification and the verification datafile.
	-t --test, followed by the file path for the datafile to be used 
	for verification
	-v --verbose, output debugging information to the console 
	-s --show, output the results of the verification to the terminal
	-w --weight, weight the number of nearest neighbor counts 
	by class prevalences.
	'

	validate_help = '
"validate" takes a classifier created by make, and another datafile
to be used as a validation dataset. The parameters for which attributes to 
use, the list of permissible attribute values for discrete attributes, and the 
binning information for continuous attributes is copied from the 
classification dataset. Each instance in the validation
dataset is classified, and the inferred classes are returned.

Options:
  In addition to the options below, the options for "make" apply to 
  both the classification and the validation datafile.
  -t --test, followed by the file path for the datafile to be used 
  for validation
  -v --verbose, output debugging information to the console 
  -s --show, output the results of the validation to the terminal
  -w --weight, weight the number of nearest neighbor counts 
  by class prevalences.
  '

	partition_help = '
"partition" takes a dataset and partitions it into a dataset and 
a list of instances for the fold, according to the parameter settings.

Options:
	-f --folds, number of cross-validation folds (default is leave-one-out)
	-r --reps, number of repetitions; if > 1, a random selection of 
		instances to be included in each fold will be applied
	'

	cross_help = '
"cross": When verifying the accuracy of a ML tool, it is common practice
to train the tool on a subset of the instances in a datafile, and then 
test that trained tool on the instances excluded from the subset. 
Two schemes are: leave one out, where a single instance is kept aside 
for testing; and n-fold partitioning, where n is often chosen to be 10. 
The training and testing is repeated for every possible fold.
For example, suppose the total dataset has 700 instances. That would 
give 70 instances for each fold, in the case of 10-fold partitioning. 
Thus, 70 instances would be kept aside and the tool trained on the 
remaining 630 instances, and this process would be repeated 10 times
to ensure that testing is done on all the instances.
Picking the instances to be kept aside can be done sequentially or 
randomly. If random, more repetitions are necessary to obtain some
degree of statistical validity.
An important consideration is that when training on a subset of instances, 
the dataset characteristics used in the training NOT be those of the 
whole dataset. For example, the maximum and minimum values for continuous 
attributes need to be recalculated for the subset, and the map of unique
values for discrete attributes may be different also for the subset 
compared to the whole dataset. 

Usage: v run hamnn.v cross -s datasets/iris.tab

Options:
  -a --attributes, the number of attributes (picked from the list of 
      ranked attributes) to be used in training the classifier
  -b --bins, eg, "3,6" specifies the lower and upper limits for the 
      number of slices or bins for continuous attributes;
  -f --folds, number of cross-validation folds (default is leave-one-out)
  -r --reps, number of repetitions; if > 1, a random selection of 
      instances to be included in each fold will be applied (TODO);
  -s --show, output to the console the results of the cross-validation;
  -v --verbose, output debugging information to the console;
  -w --weight, weight the number of nearest neighbor counts by 
      class prevalences;
  -x --exclude, exclude missing values from rank value calculations;

'

	explore_help = '
"explore" runs a series of cross-validations over a range of parameter 
settings, used when seeking optimal values for parameters. A parameter 
range can be specified with up to 3 integers, with the first two for 
lower and upper ends of the range, and the 3rd integer (optional) for
the interval. For example, --bins 2,12,3 would indicate to do 
cross-validations for bins settings of 2, 5, 8, and 11. 

Usage: v run hamnn.v explore -s datasets.iris.translation_tab 

Options:
  -a --attributes, a range for the number of attributes (picked from the list
      of ranked attributes) to be used in training the classifier;
  -b --bins, a range for the number of bins for continuous attributes;
  -f --folds, number of cross-validation folds (default is leave-one-out)
  -r --reps, number of repetitions; if > 1, a random selection of 
      instances to be included in each fold will be applied (TODO);
  -s --show, output to the console the results of the cross-validation;
  -v --verbose, output debugging information to the console;
  -w --weight, weight the number of nearest neighbor counts by 
      class prevalences;
  -x --exclude, exclude missing values from rank value calculations;
'
)