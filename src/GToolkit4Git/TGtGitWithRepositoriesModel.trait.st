Trait {
	#name : 'TGtGitWithRepositoriesModel',
	#instVars : [
		'repositoriesModel'
	],
	#category : 'GToolkit4Git-Model'
}

{ #category : 'api - repositories model' }
TGtGitWithRepositoriesModel >> hasRepositories [
	"Return a true if repositories model is assigned to the receiver, false otherwise"
	<return: #Boolean>

	^ repositoriesModel notNil
]

{ #category : 'api - repositories model' }
TGtGitWithRepositoriesModel >> onRepositoriesModelChanged [
	"Is sent when a new repositories model is assigned to the view model"
	
	self explicitRequirement
]

{ #category : 'api - repositories model' }
TGtGitWithRepositoriesModel >> repositoriesModel [
	"Return a not-null repositories model assigned to the receiver view model"
	self
		assert: [ repositoriesModel notNil ]
		description: [ 'repositories model should be initialized' ].

	^ repositoriesModel
]

{ #category : 'api - repositories model' }
TGtGitWithRepositoriesModel >> repositoriesModel: aRepositoriesModel [
	"Set a not-null repositories domain model assigned to the receiver view model"
	self
		assert: [ aRepositoriesModel notNil ]
		description: [ 'repositories model must not be nil' ].

	repositoriesModel == aRepositoriesModel 
		ifTrue: [ ^ self ].

	repositoriesModel ifNotNil: [ self unsubscribeFromRepositoriesModel ].
	repositoriesModel := aRepositoriesModel.

	self onRepositoriesModelChanged.
	self subscribeToRepositoriesModel
]

{ #category : 'api - repositories model' }
TGtGitWithRepositoriesModel >> subscribeToRepositoriesModel [
	"Is sent after a new repositories model is assigned to the view model.
	It is required to unsubscribe from the domain model by implementing
	#unsubscribeFromRepositoriesModel if view model subscribes to them"
]

{ #category : 'api - repositories model' }
TGtGitWithRepositoriesModel >> unsubscribeFromRepositoriesModel [
	"Is sent before a new repositories model is assigned to the view model.
	View models that subscribe to repositories model are required to implement this methods"
]
