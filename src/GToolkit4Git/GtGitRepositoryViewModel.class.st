Class {
	#name : #GtGitRepositoryViewModel,
	#superclass : #Object,
	#traits : 'TGtGitWithRepositoryModel + TGtAnnouncer',
	#classTraits : 'TGtGitWithRepositoryModel classTrait + TGtAnnouncer classTrait',
	#instVars : [
		'iceTipRepositoryViewModel',
		'commitMessage',
		'announcer'
	],
	#category : #'GToolkit4Git-UI - View Model'
}

{ #category : #accessing }
GtGitRepositoryViewModel >> addPackage: aSymbol [
	
	self repositoryModel workingCopy addPackageNamed: aSymbol
]

{ #category : #announcer }
GtGitRepositoryViewModel >> announcer [
	^ announcer
]

{ #category : #'api - accessing' }
GtGitRepositoryViewModel >> commitMessage [
	^ commitMessage ifNil: [ GtGitCommitMessage default lastMessage ].
]

{ #category : #'api - accessing' }
GtGitRepositoryViewModel >> commitMessage: aString [ 
	commitMessage := aString
]

{ #category : #'api - actions' }
GtGitRepositoryViewModel >> executeCommit: aCommitMessage [
	GtGitCommitMessage default lastMessage: aCommitMessage.
	self commitMessage: aCommitMessage.
	self repositoryModel executeCommit: aCommitMessage.
]

{ #category : #accessing }
GtGitRepositoryViewModel >> executeCommit: aCommitMessage withChanges: changes [
	GtGitCommitMessage default lastMessage: aCommitMessage.
	self commitMessage: aCommitMessage.
	self repositoryModel executeCommit: aCommitMessage withChanges: changes.
]

{ #category : #'api - actions' }
GtGitRepositoryViewModel >> fetch [
	self repositoryModel fetch
]

{ #category : #'api - actions' }
GtGitRepositoryViewModel >> forget [
	repositoryModel forget
]

{ #category : #'api - repository' }
GtGitRepositoryViewModel >> headDescription [
	^ self hasRepository 
		ifTrue: [ iceTipRepositoryViewModel branchName ] 
		ifFalse: [ '<missing>' ]
]

{ #category : #accessing }
GtGitRepositoryViewModel >> incomingCommits [
	^ self repositoryModel incomingCommits
]

{ #category : #initialization }
GtGitRepositoryViewModel >> initialize [

	super initialize.

	announcer := Announcer new.
	Iceberg announcer weak
		when: IceRepositoryModified
		send: #onRepositoryModified:
		to: self.
	Iceberg announcer weak
		when: IceCommited
		send: #onRepositoryModified:
		to: self.
	Iceberg announcer weak
		when: IcePushed
		send: #onRepositoryModified:
		to: self.
	Iceberg announcer weak
		when: IceMergeConflictResolved
		send: #onRepositoryModified:
		to: self
]

{ #category : #testing }
GtGitRepositoryViewModel >> isCommittable [
	^ self repositoryModel isCommittable
]

{ #category : #testing }
GtGitRepositoryViewModel >> isMissing [
	^ self repositoryModel isMissing
]

{ #category : #'api - repository' }
GtGitRepositoryViewModel >> name [
	^ (self hasRepository 
		ifTrue: [ repositoryModel name ] 
		ifFalse: [ '<missing>' ]) asRopedText
]

{ #category : #testing }
GtGitRepositoryViewModel >> needsRepair [
	^ self repositoryModel repairActions size > 0 
]

{ #category : #'api - repository model' }
GtGitRepositoryViewModel >> onRepositoryModelChanged [

	"Is sent when a new repository model is assigned to the view model"

	iceTipRepositoryViewModel := IceTipRepositoryModel on:
		                             self repositoryModel repository.
]

{ #category : #callbacks }
GtGitRepositoryViewModel >> onRepositoryModified: anAnnouncement [

	(self hasRepository and: [ 
		 anAnnouncement repository = self repositoryModel repository ]) 
		ifTrue: [ 
			self announce:
				(GtRepositoryModified for: self repositoryModel) ]
]

{ #category : #accessing }
GtGitRepositoryViewModel >> outgoingCommits [

	^ (self repositoryModel isCommittable not or: [ 
		   self repositoryModel repository branch hasUpstream ])
		  ifTrue: [ self repositoryModel outgoingCommits ]
		  ifFalse: [ self repositoryModel repository head commits ]
]

{ #category : #'api - actions' }
GtGitRepositoryViewModel >> pull [
	self repositoryModel pull
]

{ #category : #'api - actions' }
GtGitRepositoryViewModel >> push [
	self repositoryModel push
]

{ #category : #'api - actions' }
GtGitRepositoryViewModel >> remove [
	self repositoryModel remove
]

{ #category : #accessing }
GtGitRepositoryViewModel >> repairStencilFor: aDropdown [
	^ self repositoryModel repairStencil dropdown: aDropdown
]

{ #category : #'api - repository' }
GtGitRepositoryViewModel >> status [
	^ (iceTipRepositoryViewModel
		ifNotNil: [ :aViewModel | aViewModel status ]
		ifNil: [ '<missing>' ]) asRopedText
]

{ #category : #accessing }
GtGitRepositoryViewModel >> statusModel [
	^ self repositoryModel statusModel
]
