Trait {
	#name : 'TGtGitWithRepositoriesViewModel',
	#instVars : [
		'repositoriesViewModel'
	],
	#category : 'GToolkit4Git-UI - View Model'
}

{ #category : 'api - repositories view model' }
TGtGitWithRepositoriesViewModel >> hasRepositoriesViewModel [
	"Return a true if repositories view model is assigned to the receiver element, false otherwise"
	<return: #Boolean>

	^ repositoriesViewModel notNil
]

{ #category : 'api - repositories view model' }
TGtGitWithRepositoriesViewModel >> onPostRepositoriesViewModelChanged [
	"I am an optional hook method that is sent after #subscribeToRepositoriesViewModel.
	I do nothing by default but allow users to perform update operations when a receiver object is already
	subscribed to announcements."
]

{ #category : 'api - repositories view model' }
TGtGitWithRepositoriesViewModel >> onRepositoriesViewModelChanged [
	"Is sent when a new repositories view model is assigned to the element.
	Note: #onRepositoriesViewModelChanged is sent before #subscribeToRepositoriesViewModel
	which means that if you perform any operation that triggers an announcement it will be ignored because the receiver
	didn't get a chance to subscribe to any announcement. Override #onPostRepositoriesViewModelChanged if you
	wish to perform an operation that requires an announcement, but keep in mind that this is not the most efficient way"

	self explicitRequirement
]

{ #category : 'api - repositories view model' }
TGtGitWithRepositoriesViewModel >> repositoriesViewModel [
	"Return a not-null repositories view model assigned to the receiver element"
	self
		assert: [ repositoriesViewModel notNil ]
		description: [ 'repositories view model should be initialized' ].

	^ repositoriesViewModel
]

{ #category : 'api - repositories view model' }
TGtGitWithRepositoriesViewModel >> repositoriesViewModel: aRepositoriesViewModel [
	"Set a not-null repositories view model assigned to the receiver element"
	self
		assert: [ aRepositoriesViewModel notNil ]
		description: [ 'repositories view model must not be nil' ].

	repositoriesViewModel == aRepositoriesViewModel 
		ifTrue: [ ^ self ].

	repositoriesViewModel ifNotNil: [ self unsubscribeFromRepositoriesViewModel ].
	repositoriesViewModel := aRepositoriesViewModel.

	self onRepositoriesViewModelChanged.
	self subscribeToRepositoriesViewModel.
	self onPostRepositoriesViewModelChanged
]

{ #category : 'api - repositories view model' }
TGtGitWithRepositoriesViewModel >> subscribeToRepositoriesViewModel [
	"Is sent after a new repositories view model is assigned to the element.
	It is required to unsubscribe from the view model or domain model by implementing
	#unsubscribeFromRepositoriesViewModel if elements subscribe to them"
]

{ #category : 'api - repositories view model' }
TGtGitWithRepositoriesViewModel >> unsubscribeFromRepositoriesViewModel [
	"Is sent before a new repositories view model is assigned to the element.
	Elements that subscribe to repositories view model in domain model are required to implement this methods."
]
