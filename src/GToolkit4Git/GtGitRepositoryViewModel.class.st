Class {
	#name : 'GtGitRepositoryViewModel',
	#superclass : 'Object',
	#traits : 'TGtGitWithRepositoryModel',
	#classTraits : 'TGtGitWithRepositoryModel classTrait',
	#instVars : [
		'iceTipRepositoryViewModel',
		'commitMessage'
	],
	#category : 'GToolkit4Git-UI - View Model'
}

{ #category : 'api - accessing' }
GtGitRepositoryViewModel >> commitMessage [
	^ commitMessage ifNil: [ GtGitCommitMessage default lastMessage ].
]

{ #category : 'api - accessing' }
GtGitRepositoryViewModel >> commitMessage: aString [ 
	commitMessage := aString
]

{ #category : 'api - actions' }
GtGitRepositoryViewModel >> executeCommit: aCommitMessage [
	GtGitCommitMessage default lastMessage: aCommitMessage.
	self commitMessage: aCommitMessage.
	self repositoryModel executeCommit: aCommitMessage.
]

{ #category : 'api - repository' }
GtGitRepositoryViewModel >> headDescription [
	^ self hasRepository 
		ifTrue: [ iceTipRepositoryViewModel branchName ] 
		ifFalse: [ '<missing>' ]
]

{ #category : 'api - repository' }
GtGitRepositoryViewModel >> name [
	^ self hasRepository 
		ifTrue: [ iceTipRepositoryViewModel descriptionWithDecoration ] 
		ifFalse: [ '<missing>' ]
]

{ #category : 'api - repository model' }
GtGitRepositoryViewModel >> onRepositoryModelChanged [
	"Is sent when a new repository model is assigned to the view model"
	
	iceTipRepositoryViewModel := IceTipRepositoryModel on: self repositoryModel repository
]

{ #category : 'api - repository' }
GtGitRepositoryViewModel >> status [
	^ iceTipRepositoryViewModel
		ifNotNil: [ :aViewModel | aViewModel status asRopedText ]
		ifNil: [ '<missing>' ]
]
