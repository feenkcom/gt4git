Class {
	#name : #GtGitSourceDirectoryCreationForm,
	#superclass : #Object,
	#instVars : [
		'directory',
		'repositoryModel',
		'button'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> acceptAction [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Accept';
		action: [ :aModel :aButton | 
			[ | model |
			model := IceBasicProject onRepository: self repositoryModel repository.
			model
				sourceDirectory: (self directory relativeTo: self repositoryModel repository repositoryDirectory)
						pathString.
			model fileFormat: IceLibgitTonelWriter.
			self assert: model repositoryProperties fileFormat = IceLibgitTonelWriter.	"Set the project in the repository"
			self repositoryModel workingCopy project: model.
			self repositoryModel announceRepositoryModified.
			button
				inUIProcessDo: [ button dispatchEvent: BrDropdownHideWish new.
					button phlow fireUpdateWish ] ] on: Error do: #debug ];
		beCommitAction
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> asElement [
	| viewModel |
	viewModel := self asGtMagritteViewModel.
	viewModel actions first
		installOn: [ :aModel :aButton :aMemento | 
			aButton
				withAsyncSinkDo: [ :anElementSink | 
					anElementSink
						sink: AsyncPeekSink new;
						whenUpdate: [ :theButton :aSink | 
							| aStatus |
							aStatus := aSink value.
							theButton enabled: aStatus isValid ].
					aMemento overallStatus observe: anElementSink ] ].
	viewModel
		onElementCreated: [ :aFrame | 
			BlFocusFinder new
				direction: BlFocusSearchDirectionForward new;
				root: aFrame;
				referenceElement: nil;
				nextFocusDo: #requestFocus ifNone: [  ] ].
	^ viewModel asElement padding: (BlInsets all: 5)
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> button [
	^ button
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> button: anObject [
	button := anObject
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> directory [
	^ directory
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> directory: anObject [
	directory := anObject
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> directoryDescription [
	<magritteDescription>
	^ MADirectoryDescription new
		label: 'Location';
		priority: 1;
		kind: AbstractFileReference;
		display: [ :aFileRef | 
			(aFileRef relativeTo: self repositoryModel repository repositoryDirectory)
				pathString ];
		accessor: #directory
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> repositoryModel [
	^ repositoryModel
]

{ #category : #accessing }
GtGitSourceDirectoryCreationForm >> repositoryModel: anObject [
	repositoryModel := anObject.
	self directory: (self repositoryModel repository repositoryDirectory / 'src') ensureCreateDirectory
]
