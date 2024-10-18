Trait {
	#name : #TGtGitWithRepositoryViewModel,
	#instVars : [
		'repositoryViewModel'
	],
	#category : #'GToolkit4Git-UI - View Model'
}

{ #category : #'api - repository view model' }
TGtGitWithRepositoryViewModel >> hasRepositoryViewModel [
	"Return a true if repository view model is assigned to the receiver element, false otherwise"
	<return: #Boolean>

	^ repositoryViewModel notNil
]

{ #category : #'api - repository view model' }
TGtGitWithRepositoryViewModel >> onPostRepositoryViewModelChanged [
	"I am an optional hook method that is sent after #subscribeToRepositoryViewModel.
	I do nothing by default but allow users to perform update operations when a receiver object is already
	subscribed to announcements."
]

{ #category : #'api - repository view model' }
TGtGitWithRepositoryViewModel >> onRepositoryViewModelChanged [
	"Is sent when a new repository view model is assigned to the element.
	Note: #onRepositoryViewModelChanged is sent before #subscribeToRepositoryViewModel
	which means that if you perform any operation that triggers an announcement it will be ignored because the receiver
	didn't get a chance to subscribe to any announcement. Override #onPostRepositoryViewModelChanged if you
	wish to perform an operation that requires an announcement, but keep in mind that this is not the most efficient way"

	self explicitRequirement
]

{ #category : #'api - repository view model' }
TGtGitWithRepositoryViewModel >> repositoryViewModel [
	"Return a not-null repository view model assigned to the receiver element"
	self
		assert: [ repositoryViewModel notNil ]
		description: [ 'repository view model should be initialized' ].

	^ repositoryViewModel
]

{ #category : #'api - repository view model' }
TGtGitWithRepositoryViewModel >> repositoryViewModel: aRepositoryViewModel [
	"Set a not-null repository view model assigned to the receiver element"
	self
		assert: [ aRepositoryViewModel notNil ]
		description: [ 'repository view model must not be nil' ].

	repositoryViewModel == aRepositoryViewModel 
		ifTrue: [ ^ self ].

	repositoryViewModel ifNotNil: [ self unsubscribeFromRepositoryViewModel ].
	repositoryViewModel := aRepositoryViewModel.

	self onRepositoryViewModelChanged.
	self subscribeToRepositoryViewModel.
	self onPostRepositoryViewModelChanged
]

{ #category : #'api - repository view model' }
TGtGitWithRepositoryViewModel >> subscribeToRepositoryViewModel [
	"Is sent after a new repository view model is assigned to the element.
	It is required to unsubscribe from the view model or domain model by implementing
	#unsubscribeFromRepositoryViewModel if elements subscribe to them"
]

{ #category : #'api - repository view model' }
TGtGitWithRepositoryViewModel >> unsubscribeFromRepositoryViewModel [
	"Is sent before a new repository view model is assigned to the element.
	Elements that subscribe to repository view model in domain model are required to implement this methods."
]
