"
I am GtGitRepositoryHistoryRecord.
I capture the state of a Iceberg git repository so that it could be recreated in the future.

In particular, I hold the following information:
- name
- originUrl
- headCommitId
- packages

"
Class {
	#name : #GtGitRepositoryHistoryRecord,
	#superclass : #Object,
	#instVars : [
		'name',
		'originUrl',
		'headCommitId',
		'packages'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #actions }
GtGitRepositoryHistoryRecord class >> capture: aRepository [
	| record |
	record := self new.
	record name: aRepository name.
	aRepository isMissing
		ifFalse: [ 
			record originUrl: aRepository originUrl.
			record headCommitId: aRepository head commit id ].
	aRepository workingCopy packages do: [ :each |
		record packages add: each name ].
	^ record
]

{ #category : #example }
GtGitRepositoryHistoryRecord class >> exampleGt4Git [
	<gtExample>
	<noTest>
	
	| repository record |
	repository := IceRepository repositoryNamed: 'gt4git'.
	repository ifNil: [ ^ self error: 'The gt4git repository is not defined' ].
	record := self capture: repository.
	self assert: record name = 'gt4git'.
	^ record
]

{ #category : #actions }
GtGitRepositoryHistoryRecord >> fork [
	"Restore the repository that I describe by first forking it from its upstream URL
	into the user's account, then cloning, creating and registering that fork"

	| login switcher fork repository |
	self 
		assert: GhTokenHolder hasToken 
		description: 'Please set your GitHub Personal Access Token in GhTokenHolder'.

	login := GtGitHubAPITool new user login.

	switcher := GtIceRepositorySwitcher new
		sshUrl: self originUrl;
		yourself.

	fork := GtGitHubAPITool new 
		forkRepositoryOwner: switcher owner name: switcher projectName.

	repository := GtGitHubAPITool new
		repositoryOwner: login name: switcher projectName.

	self assert: repository fork description: 'Fork failed'.

	switcher sshUrl: (repository at: #ssh_url).

	switcher directory exists
		ifTrue: [ ^ self error: switcher directory printString , ' already exists, cannot clone' ].

	switcher 
		useLibgitCLI;
		cloneAndCreate;
		register.

	^ switcher iceRepository head commit id = self headCommitId
]

{ #category : #'gt extensions' }
GtGitRepositoryHistoryRecord >> gtForkActionFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Fork';
		tooltip: 'Fork from upstream, then clone, create and register';
		priority: 40;
		action: [ self fork ]
]

{ #category : #'gt extensions' }
GtGitRepositoryHistoryRecord >> gtRestoreActionFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Restore';
		tooltip: 'Clone, create and register from upstream';
		priority: 30;
		action: [ self restore ]
]

{ #category : #'gt extensions' }
GtGitRepositoryHistoryRecord >> gtViewDetailsIn: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'name' . self name }.
			{ 'origin' . self originUrl ifNil: [ '' ] . self originUrl }.
			{ 'commit' . self headCommitId ifNil: [ '' ] . self headCommitId }.
			{ 'packages'
				. (', ' join: self packages)
				. self packages } 
		} ];
		column: 'key' text: #first weight: 0.5;
		column: 'value' text: #second;
		send: #last
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> headCommitId [
	^ headCommitId
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> headCommitId: aHash [
	headCommitId := aHash
]

{ #category : #testing }
GtGitRepositoryHistoryRecord >> includesPackageNamed: packageName [
	^ self packages includes: packageName
]

{ #category : #initialization }
GtGitRepositoryHistoryRecord >> initialize [
	super initialize.
	packages := OrderedCollection new
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> name [
	^ name
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> name: aString [
	name := aString
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> originUrl [
	^ originUrl
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> originUrl: aString [
	originUrl := aString
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> packages [
	^ packages
]

{ #category : #printing }
GtGitRepositoryHistoryRecord >> printOn: stream [
	super printOn: stream.
	stream
		nextPut: $(;
		nextPutAll: self name;
		nextPut: $)
]

{ #category : #actions }
GtGitRepositoryHistoryRecord >> restore [
	"Restore the repository that I describe by cloning it from its upstream URL, creating and registering it"

	| switcher |
	switcher := GtIceRepositorySwitcher new
		sshUrl: self originUrl;
		yourself.

	switcher directory exists
		ifTrue: [ ^ self error: switcher directory printString , ' already exists, cannot clone' ].

	switcher 
		useLibgitCLI;
		cloneAndCreate;
		register.

	^ switcher iceRepository head commit id = self headCommitId
]
