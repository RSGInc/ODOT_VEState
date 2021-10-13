# ODOT VE-State with TMIP/EMAT

This document serves as a set of basic instructions to setup visioneval and tmip/emat, defining model structure, developing inputs for scenarios, and running scenarios.

## Installation

This section will outline the installation instructions for various components needed to run TMIP/EMAT scenarios.

### Install Visioneval

Clone https://github.com/VisionEval/VisionEval-Dev.

More details to come here......

### Install TMIP/EMAT

Follow the instructions as listed in https://tmip-emat.github.io/source/emat.install.html

More details need to be added here.....

### TMIP/EMAT base model

Clone https://github.com/tmip-emat/tmip-emat-ve/.

This is the base template of ODOT VE-State model

## Model Structure

The TMIP/EMAT ODOT VE-State model has following file structure:

1. VE-State - This is the base ODOT VE-State model with inputs containing files from "Common" scenario that ODOT has shared. The *defs/run_parameters.json* file was modified to run for future year. The base model setup contains additional scripts that are required to produce metrics from the Datastore. These scripts are called from *run_model.R* script and the output is produced in the *outputs* folder. Additional metrics can be output by updating relevant scripts.
2. BaseDatastore - This folder should contain the Datastore files/folder containing information on historical runs. During a tmip/emat model run the content of this folder is copied to the temporary location and is referenced in the *run_model.R* script.
3. scenario_inputs - This folder contains scenario input files and it follows the same structure as VEScenario model
4. vestate-emat-files - This file contains the tmip/emat configuration files.
5. emat_vestate.py - This python file defines a VE-State class wrapped around tmip/emat files.
6. VEState-EMAT.ipynb - This is a jupyter notebook that runs the ODOT-VEState scenarios.
7. Temporary - This folder will be used by tmip/emat model to host multiple visioneval model run during a tmip/emat scenario run.

More details on how these files function and what they do.

### VE-State

This is the base ODOT VE-State model. The inputs folder contain input files from "Common" scenario. The current setup of the base model is run for year 2020, 2025, 2030, 2035, 2040, 2045, and 2050 with 2010 as base year. The *run_model.R* script is similar to *run_model.R* script found in visioneval models with additional post processing scripts sourced at the end of the script. These scripts **CalcMetroMeasuresFunction.R** will output **metro_measures_XXXX.csv** for each model run year and **CalcStateValidationMeasuresFunction.R** will output **state_validation_measures.csv** in the *output* folder.

![image-20211011135017939](.\images\ve_state_base_setup.png)

### BaseDatastore

This folder should contain the *Datastore* folder created from a historical model runs and the *ModelState.Rda* file that goes along with it.

![image-20211011135756376](.\images\base_datastore.png)

### scenario_inputs

The folder contains the scenario input files that the tmip/emat model will choose from to build scenarios. The structure of this folder will follow the VEScenario model in visioneval repository.

![image-20211011131902720](.\images\scenario_inputs.png)

### vestate-emat-files

This folder contains the tmip/emat configuration files. There are two kind of files, model configuration file and scenario scope file.

- vestate-model-config.yml - This is a model configuration file that has a list of variables that defines paths to model setup, R setup, etc.

  - model_path - relative path to base ODOT VE-State model
  - model_archive - user location to where the tmip/model will archive scenario runs
  - model_source - absolute path to model source code
  - model_hist_datastore - absolute path to where the datastore from historical runs should be copied from
  - model_temp_folder - absolute path to where the tmip/emat model will create scenario setup and run scenarios
  - rel_output_path - path relative to the base model "VE-State" where the metric files are located and should be read from
  - r_library_path - absolute path to the r library (visioneval version "ve-lib") where the VE modules are installed
  - r_runtime_path - absolute path to the "runtime" directory created by the visioneval setup
  - r_executable - absolute path to the R application

  ```yaml
  model_path: ./VE-State
  model_archive: ~/vision-eval/VisionEval-Archive
  model_source: E:/Projects/Clients/odot/ODOT_VEState/Github/built/mm_model/4.1.0/runtime/models/VE-State
  model_hist_datastore: E:/Projects/Clients/odot/ODOT_VEState/Github/sources/models/VE-State-EMAT/BaseDatastore
  model_temp_folder: E:/Projects/Clients/odot/ODOT_VEState/Github/sources/models/VE-State-EMAT/Temporary
  
  rel_output_path: ./output
  r_library_path: E:/Projects/Clients/odot/ODOT_VEState/Github/built/mm_model/4.1.0/ve-lib
  r_runtime_path: E:/Projects/Clients/odot/ODOT_VEState/Github/built/mm_model/4.1.0/runtime
  r_executable: E:/Projects/Clients/odot/ODOT_VEState/R_4_1_0/App/R-Portable/bin
  ```

- vestate-scope.yml - This is a scenario configuration file. It provides definition of various inputs and outputs that the tmip/emat uses/controls to develop and run scenarios, and build and visualize meta-models. The details about the scope files and various parameters used can be found here: https://tmip-emat.github.io/source/emat.scope/scope.file.html. There are four basic methods in which the scenario input files can be updated by tmip/emat model:

  - Manipulation - This method can be used to pass on the parameters to the tmip/emat model which are then used within the tmip/emat model to manipulate the input file. In the following example when the parameter (python dictionary) is passed on to the tmip/emat model it contains a value generated randomly from the pert distribution as defined. This value can then be used to manipulate the income forecasts for the year 2025 by multiplying with the value contained in the parameter for `Income2025` key.

    ```yaml
        Income2025:
            # MANIPULATION
            # This parameter is used to manipulate the income forecast for
            # year 2025 by multiplying with the value generated
            shortname: HH Income
            ptype: uncertainty
            dtype: float
            desc: Household Income per Capita multiplier for Year 2025
            default: 1
            max: 1.10
            min: 0.90
            dist:
                name: pert
                peak: 1
    ```

    

  - Injection - This method can be used to replace a value in the scenario input file template when building the scenario setup. The current TMIP/EMAT setup for ODOT VE-State does not contain this method but following is an excerpt from tmip/emat VERSPM model obtained from https://github.com/tmip-emat/tmip-emat-ve. In this example the scenario input file contains tokens (keywords) which are replaced with the values passed on to the tmip/emat model.

    ```yaml
        Transit:
            # INJECTION
            # This parameter uses a template file to create a new input file
            # in the `T` group by injecting the relevant values directly
            # into the file being manipulated.
            shortname: Transit
            desc: Level of public transit service, relative to current
            ptype: policy lever
            dtype: float
            default: 1.0
            min: 0.5
            max: 4.0
    ```

  - Mixture - This method can be used to interpolate values between two extreme scenario input files. In the following example two versions of file with specified SOV diversion rates for AP scenario and STS scenario are interpolated when building scenario. 

    ```yaml
        Bicycles:
            # MIXTURE
            # This parameter uses a template file to create a new input file
            # in the `B` group by injecting the relevant value directly
            # into the file being manipulated.
            desc: Network improvements, incentives, and technologies that encourage
              bicycling and other light-weight vehicle travel.
            ptype: policy lever
            dtype: float
            default: 0.0
            min: 0.0 # SOV diversion rates from AP scenario
            max: 1.0 # SOV diversion rates from STS scenario
            dist:
                name: pert
                peak: 0.1
    ```

  - Categorical - This method can be used when the pre-specified input files should not be altered when constructing scenarios. In the following example two sets of fee structures are defined one from AP scenario and other from STS scenario. The files are used as is without any manipulation based on whether values generated are `ap` or `sts`.

    ```yaml
        VMTFees:
            # CATEGORICAL
            # This parameter accepts the same two sets of scenario input files
            # as the usual VisionEval scenario manager for `F`, and uses one or
            # the other explicitly, defining a categorical input.
            shortname: VMT Fees
            desc: Extend of fees that can be levied for VMT
            ptype: policy level
            dtype: cat
            default: ap
            values:
                - ap    # VMT fees from AP scenario
                - sts  # VMT fees from STS scenario
    ```

  These are just the basic methods and a combination of these methods can be used to create a more complex scenario input definition.

  The details on output specifications can be found here: https://tmip-emat.github.io/source/emat.scope/measures.html#output-measures

  In the following example the tmip/emat model looks for "state_validation_measures.csv" file in the output folder and extracts value where the first column has "HouseholdDvmt" (row of data-frame) and first row has "2025" (column of data-frame).

  ```yaml
      StateDvmt2025:
          kind: info
          desc: Daily vehicle miles traveled by households in 2025
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2025
  ```
  
  Here's an example of full scope file:
  
  ```yaml
  ---
  # VEState Scope Definition
  
  scope:
      name: VEState
      desc: VisionEval State Strategic Planning Model
  
  inputs:
  
      Income2025:
          # MANIPULATION
          # This parameter is used to manipulate the income forecast for
          # year 2025 by multiplying with the value generated
          shortname: HH Income
          ptype: uncertainty
          dtype: float
          desc: Household Income per Capita multiplier for Year 2025
          default: 1
          max: 1.10
          min: 0.90
          dist:
              name: pert
              peak: 1
      Income2030:
          # MANIPULATION
          # This parameter is used to manipulate the income forecast for
          # year 2030 by multiplying with the value generated
          shortname: HH Income
          ptype: uncertainty
          dtype: float
          desc: Household Income per Capita multiplier for Year 2030
          default: 1
          max: 1.20
          min: 0.80
          dist:
              name: pert
              peak: 1
      Income2035:
          # MANIPULATION
          # This parameter is used to manipulate the income forecast for
          # year 2035 by multiplying with the value generated
          shortname: HH Income
          ptype: uncertainty
          dtype: float
          desc: Household Income per Capita multiplier for Year 2035
          default: 1
          max: 1.25
          min: 0.75
          dist:
              name: pert
              peak: 1
      Income2040:
          # MANIPULATION
          # This parameter is used to manipulate the income forecast for
          # year 2040 by multiplying with the value generated
          shortname: HH Income
          ptype: uncertainty
          dtype: float
          desc: Household Income per Capita multiplier for Year 2040
          default: 1
          max: 1.25
          min: 0.75
          dist:
              name: pert
              peak: 1
      Income2045:
          # MANIPULATION
          # This parameter is used to manipulate the income forecast for
          # year 2045 by multiplying with the value generated
          shortname: HH Income
          ptype: uncertainty
          dtype: float
          desc: Household Income per Capita multiplier for Year 2045
          default: 1
          max: 1.25
          min: 0.75
          dist:
              name: pert
              peak: 1
      Income2050:
          # MANIPULATION
          # This parameter is used to manipulate the income forecast for
          # year 2050 by multiplying with the value generated
          shortname: HH Income
          ptype: uncertainty
          dtype: float
          desc: Household Income per Capita multiplier for Year 2050
          default: 1
          max: 1.30
          min: 0.70
          dist:
              name: pert
              peak: 1
  
      Bicycles:
          # MIXTURE
          # This parameter uses a template file to create a new input file
          # in the `B` group by injecting the relevant value directly
          # into the file being manipulated.
          desc: Network improvements, incentives, and technologies that encourage
            bicycling and other light-weight vehicle travel.
          ptype: policy lever
          dtype: float
          default: 0.0
          min: 0.0 # SOV diversion rates from AP scenario
          max: 1.0 # SOV diversion rates from STS scenario
          dist:
              name: pert
              peak: 0.1
  
      VMTFees:
          # CATEGORICAL
          # This parameter accepts the same two sets of scenario input files
          # as the usual VisionEval scenario manager for `F`, and uses one or
          # the other explicitly, defining a categorical input.
          shortname: VMT Fees
          desc: Extend of fees that can be levied for VMT
          ptype: policy level
          dtype: cat
          default: ap
          values:
              - ap    # VMT fees from AP scenario
              - sts  # VMT fees from STS scenario
  
  outputs:
  
      StateDvmt2020:
          kind: info
          desc: Daily vehicle miles traveled by households in 2020
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2020
      StateDvmt2025:
          kind: info
          desc: Daily vehicle miles traveled by households in 2025
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2025
      StateDvmt2030:
          kind: info
          desc: Daily vehicle miles traveled by households in 2030
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2030
      StateDvmt2035:
          kind: info
          desc: Daily vehicle miles traveled by households in 2035
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2035
      StateDvmt2040:
          kind: info
          desc: Daily vehicle miles traveled by households in 2040
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2040
      StateDvmt2045:
          kind: info
          desc: Daily vehicle miles traveled by households in 2045
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2045
      StateDvmt2050:
          kind: info
          desc: Daily vehicle miles traveled by households in 2050
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdDvmt
              - 2050
      StateHhCarSvcDvmt2020:
          kind: info
          desc: Daily vehicle miles traveled by households in car service 2020
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdCarSvcDvmt
              - 2020
      StateHhCarSvcDvmt2025:
          kind: info
          desc: Daily vehicle miles traveled by households in car service 2025
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdCarSvcDvmt
              - 2025
      StateHhCarSvcDvmt2030:
          kind: info
          desc: Daily vehicle miles traveled by households in car service 2030
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdCarSvcDvmt
              - 2030
      StateHhCarSvcDvmt2035:
          kind: info
          desc: Daily vehicle miles traveled by households in car service 2035
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdCarSvcDvmt
              - 2035
      StateHhCarSvcDvmt2040:
          kind: info
          desc: Daily vehicle miles traveled by households in car service 2040
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdCarSvcDvmt
              - 2040
      StateHhCarSvcDvmt2045:
          kind: info
          desc: Daily vehicle miles traveled by households in car service 2045
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdCarSvcDvmt
              - 2045
      StateHhCarSvcDvmt2050:
          kind: info
          desc: Daily vehicle miles traveled by households in car service 2050
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - HouseholdCarSvcDvmt
              - 2050
      StateTotalDvmt2020:
          kind: info
          desc: Daily vehicle miles traveled by households in total - vehicles, com service, and public transit 2020
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalDvmt
              - 2020
      StateTotalDvmt2025:
          kind: info
          desc: Daily vehicle miles traveled by households in total - vehicles, com service, and public transit 2025
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalDvmt
              - 2025
      StateTotalDvmt2030:
          kind: info
          desc: Daily vehicle miles traveled by households in total - vehicles, com service, and public transit 2030
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalDvmt
              - 2030
      StateTotalDvmt2035:
          kind: info
          desc: Daily vehicle miles traveled by households in total - vehicles, com service, and public transit 2035
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalDvmt
              - 2035
      StateTotalDvmt2040:
          kind: info
          desc: Daily vehicle miles traveled by households in total - vehicles, com service, and public transit 2040
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalDvmt
              - 2040
      StateTotalDvmt2045:
          kind: info
          desc: Daily vehicle miles traveled by households in total - vehicles, com service, and public transit 2045
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalDvmt
              - 2045
      StateTotalDvmt2050:
          kind: info
          desc: Daily vehicle miles traveled by households in total - vehicles, com service, and public transit 2050
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalDvmt
              - 2050
      StateTotalGGE2020:
          kind: info
          desc: Total gasoline consumed by light and heavy duty vehicles in 2020
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalGGE
              - 2020
      StateTotalGGE2025:
          kind: info
          desc: Total gasoline consumed by light and heavy duty vehicles in 2025
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalGGE
              - 2025
      StateTotalGGE2030:
          kind: info
          desc: Total gasoline consumed by light and heavy duty vehicles in 2030
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalGGE
              - 2030
      StateTotalGGE2035:
          kind: info
          desc: Total gasoline consumed by light and heavy duty vehicles in 2035
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalGGE
              - 2035
      StateTotalGGE2040:
          kind: info
          desc: Total gasoline consumed by light and heavy duty vehicles in 2040
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalGGE
              - 2040
      StateTotalGGE2045:
          kind: info
          desc: Total gasoline consumed by light and heavy duty vehicles in 2045
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalGGE
              - 2045
      StateTotalGGE2050:
          kind: info
          desc: Total gasoline consumed by light and heavy duty vehicles in 2050
          transform: none
          metamodeltype: linear
          parser:
              file: state_validation_measures.csv
              loc:
              - TotalGGE
              - 2050
  ```
  

### emat_vestate.py

The ODOT VE-State tmip/emat is a "File-Based Model" as detailed here: https://tmip-emat.github.io/source/emat.models/files.html. This python script creates a wrapper around  tmip/emat core model class `FilesCoreModel`  and overrides some basic functionality to run VE-State scenario. There are six functions that are overridden.

* Initialization (\_\_init\_\_) - The function that initializes the `VEStateModel` class. Following is a snapshot of the function:

  ```python
  	def __init__(self, db=None, db_filename="vestate.db", scope=None):
  
  		# Make a temporary directory for this instance.
  		self.master_directory = tempfile.TemporaryDirectory(dir=join_norm(this_directory,'Temporary'))
  		os.chdir(self.master_directory.name)
  		_logger.warning(f"changing cwd to {self.master_directory.name}")
  		cwd = self.master_directory.name
  
  		# Housekeeping for this example:
  		# Also copy the CONFIG and SCOPE files
  		for i in ['model-config', 'scope']:
  			shutil.copy2(
  				join_norm(this_directory, 'vestate-emat-files', f"vestate-{i}.yml"),
  				join_norm(cwd, f"vestate-{i}.yml"),
  			)
  
  		if scope is None:
  			scope = Scope(join_norm(cwd, "vestate-scope.yml"))
  
  		# Initialize a new database if none was given.
  		if db is None:
  			if os.path.exists(db_filename):
  				initialize = False
  			else:
  				initialize = True
  			db = SQLiteDB(
  				db_filename,
  				initialize=initialize,
  			)
  		if db is False: # explicitly use no DB
  			db = None
  		else:
  			if scope.name not in db.read_scope_names():
  				db.store_scope(scope)
  
  		# Initialize the super class (FilesCoreModel)
  		super().__init__(
  			configuration=join_norm(cwd, "vestate-model-config.yml"),
  			scope=scope,
  			db=db,
  			name='VEState',
  			local_directory = cwd,
  		)
  		if isinstance(db, SQLiteDB):
  			self._sqlitedb_path = db.database_path
  
  		# Populate the model_path directory of the files-based model.
  		copy_tree(
  			join_norm(this_directory, 'VE-State'),
  			join_norm(cwd, self.model_path),
  		)
  
  		self._hist_datastore_dir = join_norm(self.config['model_hist_datastore'])
  
  		# Ensure that R libraries can be found.
  		r_lib = self.config['r_library_path']
  		with open(join_norm(cwd, self.model_path, '.Rprofile'), 'wt') as rprof:
  			rprof.write(f'.libPaths("{r_lib}")\n')
  
  		# Add parsers to instruct the load_measures function
  		# how to parse the outputs and get the measure values.
  
  		# # ComputedMeasures.json
  		# instructions = {}
  		# for measure in scope.get_measures():
  		# 	if measure.parser and measure.parser.get('file') == 'ComputedMeasures.json':
  		# 		instructions[measure.name] = key[measure.parser.get('key')]
  		# self.add_parser(
  		# 	MappingParser(
  		# 		"ComputedMeasures.json",
  		# 		instructions,
  		# 	)
  		# )
  
  		# CalcOregonValidationMeasures.R
  		instructions = {}
  		for measure in scope.get_measures():
  			if measure.parser and measure.parser.get('file') == 'state_validation_measures.csv':
  				if measure.parser.get('loc'):
  					instructions[measure.name] = loc[(str(j) for j in measure.parser.get('loc'))]
  				elif measure.parser.get('eval'):
  					instructions[measure.name] = eval(measure.parser.get('eval'))
  		self.add_parser(
  			TableParser(
  				"state_validation_measures.csv",
  				instructions,
  				index_col=0,
  			)
  		)
  
  ```

  The initialization function carries out following actions:

  * Creates a temporary directory and change the working directory to temporary directory.
  * Copy emat configuration files to the temporary folder.
  * Create/Connect with the database.
  * Initialize the `FilesCoreModel` class with basic parameters
  * Setup some class variables
  * Creates parsers that would parse output files the details of which can be found here: https://tmip-emat.github.io/source/emat.models/table_parse_example.html. **When updating the scope to get metrics from *new* file then a new parser should be added.**

* Setup (setup) - The part of the script setups a VE-State model run. Following is a snapshot of the function:

  ```python
  	def setup(self, params: dict):
  		"""
  		Configure the core model with the experiment variable values.
  
  		This method is the place where the core model set up takes place,
  		including creating or modifying files as necessary to prepare
  		for a VEState core model run.  When running experiments, this method
  		is called once for each core model experiment, where each experiment
  		is defined by a set of particular values for both the exogenous
  		uncertainties and the policy levers.  These values are passed to
  		the experiment only here, and not in the `run` method itself.
  		This facilitates debugging, as the `setup` method can potentially
  		be used without the `run` method, allowing the user to manually
  		inspect the prepared files and ensure they are correct before
  		actually running a potentially expensive model.
  
  		At the end of the `setup` method, a core model experiment should be
  		ready to run using the `run` method.
  
  		Args:
  			params (dict):
  				experiment variables including both exogenous
  				uncertainty and policy levers
  
  		Raises:
  			KeyError:
  				if a defined experiment variable is not supported
  				by the core model
  		"""
  		_logger.info("VEState SETUP...")
  
  		for p in self.scope.get_parameters():
  			if p.name not in params:
  				_logger.warning(f" - for {p.name} using default value {p.default}")
  				params[p.name] = p.default
  
  		super().setup(params)
  
  		# Check if we are using distributed multi-processing. If so,
  		# we'll need to copy some files into a local working directory,
  		# as otherwise changes in the files will over-write each other
  		# when different processes are working in a common directory at
  		# the same time.
  		try:
  			# First try to import the dask.distributed library
  			# and check if this code is running on a worker.
  			from dask.distributed import get_worker
  			worker = get_worker()
  		except (ValueError, ImportError):
  			# If the library is not available, or if the code is
  			# not running on a worker, then we are not running
  			# in multi-processing mode, and we can just use
  			# the main cwd as the working directory without
  			# copying anything.
  			pass
  		else:
  			# If we do find we are running this setup on a
  			# worker, then we want to set the local directory
  			# accordingly. We copy model files from the "master"
  			# working directory to the worker's local directory,
  			# if it is different (it should be). Depending
  			# on how large your core model is, you may or may
  			# not want to be copying the whole thing.
  			if self.local_directory != worker.local_directory:
  
  				# Make the archive path absolute, so all archives
  				# go back to the original directory.
  				self.archive_path = os.path.abspath(self.resolved_archive_path)
  
  				_logger.debug(f"DISTRIBUTED.COPY FROM {self.local_directory}")
  				_logger.debug(f"                   TO {worker.local_directory}")
  				copy_tree(
  					join_norm(self.local_directory, self.model_path),
  					join_norm(worker.local_directory, self.model_path),
  				)
  				self.local_directory = worker.local_directory
  
  		# The process of manipulating each input file is broken out
  		# into discrete sub-methods, as each step is loosely independent
  		# and having separate methods makes this clearer.
  		#self._manipulate_model_parameters_json(params)
  		self._manipulate_income(params)
  		self._manipulate_bikes(params)
  		self._manipulate_fees(params)
  		# self._manipulate_comsvc_vehage(params)
  		#self._manipulate_land_use(params)
  		#self._manipulate_transit(params)
  		#self._manipulate_fuel_cost(params)
  		#self._manipulate_technology_mix(params)
  		#self._manipulate_parking(params)
  		#self._manipulate_demand(params)
  		#self._manipulate_vehicle_characteristics(params)
  		#self._manipulate_driving_efficiency(params)
  		#self._manipulate_vehicle_travel_cost(params)
  		_logger.info("VEState SETUP complete")
  
  
  ```

  The actions carried out by this function are:

  * Setup default parameters.

  * Update information from workers if parallelization mode is active.

  * Update scenario inputs. There are four basic update methods as discussed above.

    * Manipulation: In this method the values in the input file are modified with values passed in the dictionary `param`. For e.g.

      ```python
      def _manipulate_income(self, params):
      		"""
      		Prepare the income input file based on a template file.
      
      		Args:
      			params (dict):
      				The parameters for this experiment, including both
      				exogenous uncertainties and policy levers.
      		"""
      
      		income_df = pd.read_csv(join_norm(scenario_input('I','azone_per_cap_inc.csv')))
      		
      		income_df.loc[income_df.Year == 2025,['HHIncomePC.2005', 'GQIncomePC.2005']] = \
      			income_df.loc[income_df.Year == 2025,['HHIncomePC.2005', 'GQIncomePC.2005']] * params['Income2025']
      		income_df.loc[income_df.Year == 2030,['HHIncomePC.2005', 'GQIncomePC.2005']] = \
      			income_df.loc[income_df.Year == 2030,['HHIncomePC.2005', 'GQIncomePC.2005']] * params['Income2030']
      		income_df.loc[income_df.Year == 2035,['HHIncomePC.2005', 'GQIncomePC.2005']] = \
      			income_df.loc[income_df.Year == 2035,['HHIncomePC.2005', 'GQIncomePC.2005']] * params['Income2035']
      		income_df.loc[income_df.Year == 2040,['HHIncomePC.2005', 'GQIncomePC.2005']] = \
      			income_df.loc[income_df.Year == 2040,['HHIncomePC.2005', 'GQIncomePC.2005']] * params['Income2040']
      		income_df.loc[income_df.Year == 2045,['HHIncomePC.2005', 'GQIncomePC.2005']] = \
      			income_df.loc[income_df.Year == 2045,['HHIncomePC.2005', 'GQIncomePC.2005']] * params['Income2045']
      		income_df.loc[income_df.Year == 2050,['HHIncomePC.2005', 'GQIncomePC.2005']] = \
      			income_df.loc[income_df.Year == 2050,['HHIncomePC.2005', 'GQIncomePC.2005']] * params['Income2050']
      
      		out_filename = join_norm(
      			self.resolved_model_path, 'inputs', 'azone_per_cap_inc.csv'
      		)
      		_logger.debug(f"writing updates to: {out_filename}")
      		# with open(out_filename, 'wt') as f:
      		# 	f.write(y)
      		income_df.to_csv(out_filename, index=False)
      ```

    * Injection: In this method a token in the template file is replaced by the value passed in the dictionary `params`. For e.g.

      ```python
      	def _manipulate_fuel_cost(self, params):
      		"""
      		Prepare the fuel and electric input file based on a template file.
      
      		Args:
      			params (dict):
      				The parameters for this experiment, including both
      				exogenous uncertainties and policy levers.
      		"""
      
      		computed_params = {}
      		computed_params['FuelCost'] = params['FuelCost']
      		computed_params['ElectricCost'] = params['ElectricCost']
      
      		with open(scenario_input('G','azone_fuel_power_cost.csv.template'), 'rt') as f:
      			y = f.read()
      
      		for n in computed_params.keys():
      			y = y.replace(
      				f"__EMAT_PROVIDES_{n}__",  # the token to replace
      				f"{computed_params[n]:.3f}",  # the value to replace it with (as a string)
      			)
      
      		out_filename = join_norm(
      			self.resolved_model_path, 'inputs', 'azone_fuel_power_cost.csv'
      		)
      		_logger.debug(f"writing updates to: {out_filename}")
      		with open(out_filename, 'wt') as f:
      			f.write(y)
      ```

    * Categorical - In this method inputs are selected based on the value observed in the dictionary `params`. For e.g.

      ```python
      def _manipulate_fees(self, params, ):
          # return self._manipulate_by_mixture(params, 'VMTFees', 'F',)
          cat_mapping = {
              'ap': '1',
              'sts': '2',
          }
          return self._manipulate_by_categorical_drop_in(params, 'VMTFees', cat_mapping, 'F')
      
      def _manipulate_by_categorical_drop_in(self, params, cat_param, cat_mapping, ve_scenario_dir):
          """
                  Copy in the relevant input files.
      
                  Args:
                      params (dict):
                          The parameters for this experiment, including both
                          exogenous uncertainties and policy levers.
                  """
          scenario_dir = cat_mapping.get(params[cat_param])
          for i in os.scandir(scenario_input(ve_scenario_dir,scenario_dir)):
              if i.is_file():
                  shutil.copyfile(
                      scenario_input(ve_scenario_dir,scenario_dir,i.name),
                      join_norm(self.resolved_model_path, 'inputs', i.name)
                  )
      ```

    * Mixture - In this method the inputs are interpolated between two sets of values based on the weights observed in the dictionary `params`. For e.g.

      ```python
      def _manipulate_bikes(self, params):
          """
      	Prepare the biking input file based on a template file.
      
      	Args:
          	params (dict):
      		The parameters for this experiment, including both
      		exogenous uncertainties and policy levers.
      	"""
          return self._manipulate_by_mixture(params, 'Bicycles', 'B',)
      
      def _manipulate_by_mixture(self, params, weight_param, ve_scenario_dir, no_mix_cols=('Year', 'Geo',)):
      
          weight_2 = params[weight_param]
          weight_1 = 1.0-weight_2
      
          # Gather list of all files in directory "1", and confirm they
          # are also in directory "2"
          filenames = []
          for i in os.scandir(scenario_input(ve_scenario_dir,'1')):
              if i.is_file():
                  filenames.append(i.name)
                  f2 = scenario_input(ve_scenario_dir,'2', i.name)
                  if not os.path.exists(f2):
                      raise FileNotFoundError(f2)
      
                      for filename in filenames:
                          df1 = pd.read_csv(scenario_input(ve_scenario_dir,'1',filename))
                          df2 = pd.read_csv(scenario_input(ve_scenario_dir,'2',filename))
      
                          float_mix_cols = list(df1.select_dtypes('float').columns)
                          for j in no_mix_cols:
                              if j in float_mix_cols:
                                  float_mix_cols.remove(j)
      
                                  if float_mix_cols:
                                      df1_float = df1[float_mix_cols]
                                      df2_float = df2[float_mix_cols]
                                      df1[float_mix_cols] = df1_float * weight_1 + df2_float * weight_2
      
                                      int_mix_cols = list(df1.select_dtypes('int').columns)
                                      for j in no_mix_cols:
                                          if j in int_mix_cols:
                                              int_mix_cols.remove(j)
      
                                              if int_mix_cols:
                                                  df1_int = df1[int_mix_cols]
                                                  df2_int = df2[int_mix_cols]
                                                  df_int_mix = df1_int * weight_1 + df2_int * weight_2
                                                  df1[int_mix_cols] = np.round(df_int_mix).astype(int)
      
                                                  out_filename = join_norm(
                                                      self.resolved_model_path, 'inputs', filename
                                                  )
                                                  df1.to_csv(out_filename, index=False, float_format="%.5f")
      ```

      

* Run (run) - The part of code carries out the execution of a scenario VE-State run. Following is a snapshot of the code:

  ```python
  	def run(self):
          """
  		Run the core model.
  
  		This method is the place where the RSPM core model run takes place.
  		Note that this method takes no arguments; all the input
  		exogenous uncertainties and policy levers are delivered to the
  		core model in the `setup` method, which will be executed prior
  		to calling this method. This facilitates debugging, as the `setup`
  		method can potentially be used without the `run` method, allowing
  		the user to manually inspect the prepared files and ensure they
  		are correct before actually running a potentially expensive model.
  		When running experiments, this method is called once for each core
  		model experiment, after the `setup` method completes.
  
  		Raises:
  		    UserWarning: If model is not properly setup
  		"""
  		_logger.info("VEState RUN ...")
  
  		# Set the R path
  		os.environ['path'] = join_norm(self.config['r_executable'])+';'+os.environ['path']
  
  		# This demo uses the `Rscript` command line tool to run R
  		# programmatically.  On Windows, the tool also includes `.exe`.
  		if platform.system() == 'Windows':
  			cmd = 'Rscript.exe'
  		else:
  			cmd = 'Rscript'
  
  		# Remove existing datastore
  		# datastore_namer = re.compile(r"Datastore_202[0-9]-[0-9]+-[0-9]+_[0-9]")
  		datastore_namer = re.compile(r".*Datastore")
  		for outfolder in glob.glob(join_norm(self.local_directory, self.model_path, '*/')):
  			_logger.debug(f"VEState RUN removing: {outfolder}")
  			if datastore_namer.match(outfolder):
  				_logger.debug('VEState Removing existing Datastore ' + outfolder + ' ...')
  				remove_tree(
  					join_norm(outfolder),
  					verbose=0
  				)
  
  		# Copy the common datastore that contains information of historical runs including
  		# baseyear run
  		_logger.info('VEState Copying the historical datastore ...')
  		copy_tree(
  			self._hist_datastore_dir,
  			join_norm(self.local_directory, self.model_path),
  		)
  		# shutil.copyfile(
  		# 	join_norm(this_directory, 'ModelState.Rda'),
  		# 	join_norm(self.local_directory, self.model_path, 'ModelState.Rda'),
  		# )
  		_logger.info('VEState Finished copying the historical datastore ...')
  
  
  		# Write a small script that will run the model under VisionEval 2.0
  		with open(join_norm(self.local_directory, "vestate_runner.R"), "wt") as r_script:
  			r_script.write(f"""
  			require(visioneval)
  			source("{r_join_norm(self.config['r_runtime_path'], 'VisionEval.R')}", chdir = TRUE)
  			source("{r_join_norm(self.local_directory, self.model_path, 'run_model.R')}", echo=TRUE, chdir = TRUE)
  			#cwd <- setwd("{r_join_norm(self.local_directory, self.model_path)}")
  			#on.exit(setwd(cwd))
  			#source("run_model.R", echo=TRUE)
  			#thismodel <- openModel("{r_join_norm(self.local_directory, self.model_path)}")
  			#thismodel$run()
  			#thismodel$extract()
  			#thismodel$query(Geography=c(Type='Marea',Value='RVMPO'))
  			#Add source script
  			""")
  
  		# Ensure that R paths are set correctly.
  		r_lib = self.config['r_library_path']
  		with open(join_norm(self.local_directory, '.Rprofile'), 'wt') as rprof:
  			rprof.write(f'.libPaths("{r_lib}")\n')
  
  		# The subprocess.run command runs a command line tool. The
  		# name of the command line tool, plus all the command line arguments
  		# for the tool, are given as a list of strings, not one string.
  		# The `cwd` argument sets the current working directory from which the
  		# command line tool is launched.  Setting `capture_output` to True
  		# will capture both stdout and stderr from the command line tool, and
  		# make these available in the result to facilitate debugging.
  		self.last_run_result = subprocess.run(
  			[cmd, 'vestate_runner.R'],
  			cwd=self.local_directory,
  			capture_output=True,
  		)
  		if self.last_run_result.returncode:
  			raise subprocess.CalledProcessError(
  				self.last_run_result.returncode,
  				self.last_run_result.args,
  				self.last_run_result.stdout,
  				self.last_run_result.stderr,
  			)
  		else:
  			if not os.path.exists(join_norm(self.local_directory, self.model_path, 'output')):
  				os.mkdir(join_norm(self.local_directory, self.model_path, 'output'))
  			with open(join_norm(self.local_directory, self.model_path, 'output', 'stdout.log'), 'wb') as slog:
  				slog.write(self.last_run_result.stdout)
  
  		# VisionEval Version 2 appends timestamps to output filenames,
  		# but because we're running in a temporary directory, we can
  		# strip them down to standard filenames.
  		# import re, glob
  		# renamer = re.compile(r"(.*)_202[0-9]-[0-9]+-[0-9]+_[0-9]+(\.csv)")
  		# _logger.debug("VEState RUN renaming files")
  		# for outfile in glob.glob(join_norm(self.local_directory, self.model_path, 'output', '*.csv')):
  		# 	_logger.debug(f"VEState RUN renaming: {outfile}")
  		# 	if renamer.match(outfile):
  		# 		newname = renamer.sub(r"\1\2", outfile)
  		# 		_logger.debug(f"     to: {newname}")
  		# 		if os.path.exists(newname):
  		# 			os.remove(newname)
  		# 		os.rename(outfile, newname)
  
  		_logger.info("VEState RUN complete")
  
  ```

  The actions carried out by the function are:

  * Select R executable to run the visioneval model
  * Remove existing datastore if any present in the temporary location
  * Copy historical datastore to the temporary location
  * Write out an R script which will be called by python subprocess and executed in R (this script will run the visioneval model)
  * Dump out the log prints to a file in the output folder

* Archive (archive): This function archives the parameters used to create scenario inputs and the contents of the `output` folder. Here's a snapshot of the code

  ```python
  	def archive(self, params, model_results_path=None, experiment_id=None):
  		"""
  		Copies model outputs to archive location.
  
  		Args:
  			params (dict):
  				Dictionary of experiment variables
  			model_results_path (str, optional):
  				The archive path to use.  If not given, a default
  				archive path is constructed based on the scope name
  				and the experiment_id.
  			experiment_id (int, optional):
  				The id number for this experiment.  Ignored if the
  				`model_results_path` argument is given.
  
  		"""
  		if model_results_path is None:
  			if experiment_id is None:
  				db = getattr(self, 'db', None)
  				if db is not None:
  					experiment_id = db.get_experiment_id(self.scope.name, None, params)
  			model_results_path = self.get_experiment_archive_path(experiment_id)
  		zipname = os.path.join(model_results_path, 'run_archive')
  		_logger.info(
  			f"VEState ARCHIVE\n"
  			f" from: {join_norm(self.local_directory, self.model_path, self.rel_output_path)}\n"
  			f"   to: {zipname}.zip"
  		)
  		shutil.make_archive(
  			zipname, 'zip',
  			root_dir=join_norm(self.local_directory, self.model_path),
  			base_dir=self.rel_output_path,
  		)
  ```

### VEState-EMAT.ipynb

This is the notebook that runs the tmip/emat scenarios

### Temporary

This is the folder where the tmip/emat model will create temporary folders and run visioneval models in.

## Adding new scenario inputs

Adding new files for scenarios creation will require changes to following:

* New folder/files in the `scenario_inputs` folder.
* Adding new parameter to the `vestate-scope.yml` file.
* Defining a function that informs the tmip/emat model on how to create a scenario using the new scenario input file in `emat_vestate.py` file.
* Calling the function within the `setup`  function.

## Extracting new measures from output

Extracting new output from the measures will require following changes:

* Update the `CalcStateValidationMeasuresFunction.R` script or `CalcMetroMeasuresFunction.R` script to output relevant measure.
* Create a new parameter in the `vestate-scope.yml` file that specifies the file and location from where the measure should be extracted from.

## Debugging code

The python code can be debugged by executing the steps from jupyter notebook line by line in an anaconda prompt in an environment that has python emat package installed. There are three potential places where the python code may produce an error:

* Initialization - The potential issues could be

  * Scope improperly defined
    * Make sure that the new parameters added to the scope are properly defined if this is the case.
  * Database locked or does not exist
    * Verify that the path where the database is created exist.
    * Verify that a new file can be created in the folder
  * Unable to find file (validate that all paths exist in model configuration and wherever paths are specified)
    * Verify that all the paths exists.
  * Parser is improperly defined
    * If new output files are added to the parser then verify that the parser is defined by reviewing the tmip/emat documentation on parsers.

* Setup - The potential issues could be

  * The scope file is improperly defined

    * Make sure that the new parameters added to the scope are properly defined

  * The function that manipulate the scenario input file is incorrectly defined

    * Execute the following lines and see the values that are being passed to the function and test if the function is behaving as expected

      ```python
      import os
      import numpy as np
      import pandas as pd
      import seaborn; seaborn.set_theme()
      import plotly.io; plotly.io.templates.default = "seaborn"
      import emat
      import yaml
      from emat.util.show_dir import show_dir
      from emat.analysis import display_experiments
      import logging
      from emat.util.loggers import log_to_stderr
      log = log_to_stderr(logging.INFO)
      import emat_vestate
      import asyncio
      database_path = os.path.expanduser("~/EMAT-VE/ve2-rspm-2021-09-30.db")
      initialize = not os.path.exists(database_path)
      db = emat.SQLiteDB(database_path, initialize=initialize)
      fx = emat_vestate.VEStateModel(db=db)
      design1 = fx.design_experiments(n_samples=10, design_name='exp_10') #If the experiment by this design name was not created before
      # design1 = fx.db.read_experiment_parameters(fx.scope.name,design_name='exp_10') #If the experiment by this design name was created before
      design1
      params = design1.to_dict('records')[0]
      params
      # This is where you can test scenario input manipulation function
      test_function(params)
      ```

* Run - The potential issues could be

  * The paths are either not found or properly defined

    * Check that all the paths are properly defined

  * The R executable cannot be found

    * Execute the following lines

      ```python
      import os
      import numpy as np
      import pandas as pd
      import seaborn; seaborn.set_theme()
      import plotly.io; plotly.io.templates.default = "seaborn"
      import emat
      import yaml
      from emat.util.show_dir import show_dir
      from emat.analysis import display_experiments
      import logging
      from emat.util.loggers import log_to_stderr
      log = log_to_stderr(logging.INFO)
      import emat_vestate
      import asyncio
      database_path = os.path.expanduser("~/EMAT-VE/ve2-rspm-2021-09-30.db")
      initialize = not os.path.exists(database_path)
      db = emat.SQLiteDB(database_path, initialize=initialize)
      fx = emat_vestate.VEStateModel(db=db)
      ```

      This step should print out the temporary location where the model is setup and it will look something like this `E:\Projects\Clients\odot\ODOT_VEState\Github\sources\models\VE-State-EMAT\Temporary\tmpbiuib1jb`. After this execute the following lines.

      ```python
      design1 = fx.design_experiments(n_samples=10, design_name='exp_10') #If the experiment by this design name was not created before
      # design1 = fx.db.read_experiment_parameters(fx.scope.name,design_name='exp_10') #If the experiment by this design name was created before
      design1
      params = design1.to_dict('records')[0]
      params
      fx.setup(params)
      fx.run()
      ```

      If the model fails then check if there's a log file similar to name `Log_2021-10-06_21_26_23.txt` is created in the temporary location where model was setup `E:\Projects\Clients\odot\ODOT_VEState\Github\sources\models\VE-State-EMAT\Temporary\tmpbiuib1jb\VE-State`.

      If not then the R executable is not properly setup and you might have verify that the executable is available to the python through system environment variables.

  * The model run did not finish successfully

    * Once verified that the cause of failure of model run is not R executable but R itself then carry out the steps above.
    * Check if the log file has indication of model failure and resolve if found any.
    * If log file does not show the cause of model failure then open the command prompt and navigate to the temporary folder where VE-State model was setup
    * Run the R executable version that the tmip/emat model had called.
    * Source the `vestate_runner.R` script and verify where the model fails and resolve accordingly.





