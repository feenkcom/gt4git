Extension { #name : #IceGitCliPlatform }

{ #category : #'*GToolkit4Git' }
IceGitCliPlatform >> gtDetailsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Details';
		priority: 10;
		items: [ {
			{ 'git executable' . self gitExecutable }.
			{ 'git version' . [ self gitVersion ] on: Error do: [ '' ] }.
			{ 'valid git' . [ self validateGit ] on: Error do: [ false ] }.
			{ 'valid git setup' . [ self validateGitSetup ] on: Error do: [ false ] }.
			{ 'installed' . self isInstalled }.
			{ 'signal class' . self signalClass }.
			{ 'sign commits' . self signCommits } } ];
		column: 'Key' text: #first weight: 0.5;
		column: 'Value' text: #second;
		send: #last
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
