Extension { #name : #IceGitCliPlatform }

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform class >> gtConfigFor: composite [
	<gtClassView>
	^ composite forward
		title: 'Config';
		priority: 55;
		object: [ self current ];
		view: #gtConfigFor:
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform >> gtConfigFor: composite [
	<gtView>
	^ composite forward
		title: 'Config';
		tooltip: 'Show git config options';
		priority: 40;
		object: [ self config ];
		view: #gtItemsFor: ;
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform class >> gtDetailsFor: composite [
	<gtClassView>
	^ composite forward
		title: 'Details';
		priority: 50;
		object: [ self current ];
		view: #gtDetailsFor:
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 10;
		items: [ {
			{ 'git executable' . self gitExecutable }.
			{ 'git path resolved' . [ self resolveGitPath ] on: Error do: [ '' ] }. 
			{ 'git version' . [ self gitVersion ] on: Error do: [ '' ] }.
			{ 'git exec path' . [ self gitExecPath ] on: Error do: [ '' ] }. 
			{ 'valid git' . [ self validateGit ] on: Error do: [ false ] }.
			{ 'valid git setup' . [ self validateGitSetup ] on: Error do: [ false ] }.
			{ 'installed' . self isInstalled }.
			{ 'signal class' . self signalClass }.
			{ 'logging enabled' . self isLoggingEnabled }.
			{ 'sign commits' . self signCommits } } ];
		column: 'Key' text: #first weight: 0.5;
		column: 'Value' text: #second;
		send: #last;
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform >> gtInstallActionFor: aComposite [
	<gtAction>
	
	^ aComposite button
		label: 'Install';
		tooltip: 'Make Libgit-CLI the default Iceberg implementation';
		priority: 20;
		action: [ :element | self install ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform class >> gtInstallActionFor: aComposite [
	<gtClassAction>
	
	^ aComposite button
		label: 'Install';
		tooltip: 'Make Libgit-CLI the default Iceberg implementation';
		priority: 20;
		action: [ :element | self current install ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform class >> gtUninstallActionFor: aComposite [
	<gtClassAction>
	
	^ aComposite button
		label: 'Uninstall';
		tooltip: 'Reset the Iceberg implementation to its Libgit2 FFI implementation';
		priority: 30;
		action: [ :element | self current uninstall ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform >> gtUninstallActionFor: aComposite [
	<gtAction>
	
	^ aComposite button
		label: 'Uninstall';
		tooltip: 'Reset the Iceberg implementation to its Libgit2 FFI implementation';
		priority: 30;
		action: [ :element | self uninstall ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform >> gtValidateActionFor: aComposite [
	<gtAction>
	
	^ aComposite button
		label: 'Validate';
		tooltip: 'Validate and throw errors';
		priority: 10;
		action: [ :element | element phlow spawnObject: self validate ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform class >> gtValidateActionFor: aComposite [
	<gtClassAction>
	
	^ aComposite button
		label: 'Validate';
		tooltip: 'Validate and throw errors';
		priority: 10;
		action: [ :element | element phlow spawnObject: self current validate ]
]
