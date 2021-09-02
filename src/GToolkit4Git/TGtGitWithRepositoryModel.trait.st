Trait {
	#name : 'TGtGitWithRepositoryModel',
	#instVars : [
		'repositoryModel'
	],
	#category : 'GToolkit4Git-Model'
}

{ #category : 'api - repository model' }
TGtGitWithRepositoryModel >> hasRepository [
	"Return a true if repository model is assigned to the receiver, false otherwise"
	<return: #Boolean>

	^ repositoryModel notNil
]

{ #category : 'api - repository model' }
TGtGitWithRepositoryModel >> onRepositoryModelChanged [
	"Is sent when a new repository model is assigned to the view model"
	
	self explicitRequirement
]

{ #category : 'api - repository model' }
TGtGitWithRepositoryModel >> repositoryModel [
	"Return a not-null repository model assigned to the receiver view model"
	self
		assert: [ repositoryModel notNil ]
		description: [ 'repository model should be initialized' ].

	^ repositoryModel
]

{ #category : 'api - repository model' }
TGtGitWithRepositoryModel >> repositoryModel: aRepositoryModel [
	"Set a not-null repository domain model assigned to the receiver view model"
	self
		assert: [ aRepositoryModel notNil ]
		description: [ 'repository model must not be nil' ].

	repositoryModel == aRepositoryModel 
		ifTrue: [ ^ self ].

	repositoryModel ifNotNil: [ self unsubscribeFromRepositoryModel ].
	repositoryModel := aRepositoryModel.

	self onRepositoryModelChanged.
	self subscribeToRepositoryModel
]

{ #category : 'api - repository model' }
TGtGitWithRepositoryModel >> subscribeToRepositoryModel [
	"Is sent after a new repository model is assigned to the view model.
	It is required to unsubscribe from the domain model by implementing
	#unsubscribeFromRepositoryModel if view model subscribes to them"
]

{ #category : 'api - repository model' }
TGtGitWithRepositoryModel >> unsubscribeFromRepositoryModel [
	"Is sent before a new repository model is assigned to the view model.
	View models that subscribe to repository model are required to implement this methods"
]
