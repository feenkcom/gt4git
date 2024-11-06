Extension { #name : #PureGitUrl }

{ #category : #'*GToolkit4Git' }
PureGitUrl >> gtDetails [
	| details |
	details := {
		{ 'url' . self url }.
		{ 'scheme' . self scheme }.
		{ 'repository name' . self repositoryName }.
		{ 'owner name' . self ownerName ifNil: [ '' ] }
	}.
	self isFileUrl ifTrue: [
		details := details , {
			{ 'file url' . self fileUrl }.
			{ 'file reference' . self fileReference }
		} ].
	self isNetworkUrl ifTrue: [
		details := details , {
			{ 'host name' . self hostname }
		} ].
	self gitHubWebUrl ifNotNil: [ :gitHubWebUrl |
		details := details , {
			{ 'github web url' . gitHubWebUrl }
		} ].
	^ details
]

{ #category : #'*GToolkit4Git' }
PureGitUrl >> gtDetailsFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ self gtDetails ];
		column: 'key' text: #first;
		column: 'value' text: #second weight: 3;
		send: #last
]
