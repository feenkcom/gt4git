Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#instVars : [
		'repository',
		'status',
		'headDescription',
		'isModified'
	],
	#category : #GToolkit4Git
}

{ #category : #'instance creation' }
GtGitRepository class >> fromIcebergRepository: anIceRepository [
	^ self new repository: anIceRepository
]

{ #category : #accessing }
GtGitRepository >> gtViewIncomingCommitsFor: aView [
	<gtView>
	| incomingCommits |
	incomingCommits := GtRlIceCommitsGroup forCommits: self repository incomingCommits.
	incomingCommits commits ifEmpty: [ ^ aView ].
	
	^ (incomingCommits gtViewCommitsListFor: aView)
		title: 'Incoming commits' translated;
		priority: 10;
		actionButtonLabel: 'Merge' action: [ 
			| remoteBranch |
			remoteBranch := self repository branch upstream remote 
				remoteBranchNamed: self repository branch name 
				ifAbsent: [ self repository branch ].
			self repository workingCopy mergeCommit: remoteBranch commit.
			Iceberg announcer announce: (IceRepositoryModified for: self repository) ]
]

{ #category : #accessing }
GtGitRepository >> gtViewOutgoingCommitsFor: aView [
	<gtView>
	| outgoingCommits |
	outgoingCommits := GtRlIceCommitsGroup forCommits: self repository outgoingCommits.
	^ outgoingCommits commits
		ifEmpty: [ aView ]
		ifNotEmpty: [ 
			(outgoingCommits gtViewCommitsListFor: aView)
				title: 'Outgoing commits';
				priority: 12 ]
]

{ #category : #accessing }
GtGitRepository >> headDescription [
	^ headDescription ifNil: [ headDescription := self repository headDescription ]
]

{ #category : #accessing }
GtGitRepository >> isModified [
	^ isModified ifNil: [ isModified := self repository isModified ]
]

{ #category : #initialization }
GtGitRepository >> load [
	self status.
	self headDescription.
	self isModified
]

{ #category : #accessing }
GtGitRepository >> name [
	^ self repository name
]

{ #category : #accessing }
GtGitRepository >> repository [
	<return: #IceRepository>

	^ repository
]

{ #category : #accessing }
GtGitRepository >> repository: anIceRepository [
	repository := anIceRepository
]

{ #category : #initialization }
GtGitRepository >> reset [
	status := nil.
	headDescription := nil.
	isModified := nil
]

{ #category : #accessing }
GtGitRepository >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self repository) status ]
]
