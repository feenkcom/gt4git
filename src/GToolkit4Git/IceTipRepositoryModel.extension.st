Extension { #name : #IceTipRepositoryModel }

{ #category : #'*GToolkit4Git' }
IceTipRepositoryModel >> isModified [
	^ entity isModified
]

{ #category : #'*GToolkit4Git' }
IceTipRepositoryModel >> statusModel [
	[
		| status incoming outgoing | 

		self verifyDirectoryStructureIfMissing: [ :message | ^ {GtGitStatusMissing new} ].
		
		entity workingCopy workingCopyState isUnknownCommitState 
			ifTrue: [ ^ {GtGitStatusUnknownCommitState new message: entity workingCopy workingCopyState description} ].	
		entity workingCopy isDetached 
			ifTrue: [  ^ {GtGitStatusDetachedWorkingCopy new} ].
		(entity head isDetached and: [ entity head tags notEmpty ])
			ifTrue: [ ^ {GtGitStatusDetachedHead new} ].
		entity head isDetached 
			ifTrue: [ ^ {GtGitStatusDetachedHead new}  ].

		entity workingCopy project isUnborn
			ifTrue: [ ^ {GtGitStatusNoProject new} ].

		self isLoaded ifFalse: [ ^ {GtGitStatusNotLoaded new} ].

		status := OrderedCollection new.
		entity isModified ifTrue: [ status add: GtGitStatusUncommittedChanges new ].
		
		incoming := self incomingCommits size.
		incoming > 0 ifTrue: [ status add: (GtGitStatusIncoming new count: incoming)].
		
		outgoing := self outgoingCommits size.
		outgoing > 0 ifTrue: [ status add: (GtGitStatusOutgoing new count: outgoing)].

		
		^ status
	] 
	on: Error do: [ :error | ^ {GtGitStatusUnknownError new message: error description} ]

]
