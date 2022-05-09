Class {
	#name : #GtGitGithubPageFormStencil,
	#superclass : #BrStencil,
	#instVars : [
		'ownerEditor',
		'projectEditor',
		'aDropdown',
		'onCreated',
		'errorElement'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
GtGitGithubPageFormStencil >> create [
	^ self createMainContainer
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createCloneButton [

	| cloneButton |
	cloneButton := BrButton new.
	cloneButton aptitude: BrGlamorousButtonRectangularAptitude
		+ (BrGlamorousButtonLabelAptitude new selectedColor: Color black).
	cloneButton label: 'Clone'.
	cloneButton action: [ 
		| creator repo |
		creator := IceRepositoryCreator new
			        remote: (IceGitRemote url: ownerEditor text asString);
			        location: self projectLocation.
		[ repo := creator createRepository.
		repo register.
		aDropdown ifNotNil: [ 
			aDropdown enqueueTask: (BlTaskAction new action: [ 
					 aDropdown dispatchEvent:
						 (BrDropdownHideWish new anchor: aDropdown) ]) ].
		self onCreated value: repo ] on: IceAuthenticationError do: [ :e | self displayError: e ] ].
	cloneButton constraintsDo: [ :c | 
		c grid vertical alignTop.
		c grid horizontal alignRight ].
	^ cloneButton
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createError [

	^ errorElement := BrEditor new
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createMainContainer [
	|wrapper container|
	wrapper := BrVerticalPane new vFitContent; hExact: 300.
	container := BrHorizontalPane new
			padding: (BlInsets all: 5); matchParent.
	container addChildren: self createUrl.
	container addChild: self createCloneButton.
	wrapper addChild: container.
	wrapper addChild: self createError.
	^ wrapper
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> createUrl [

	| label |
	label := BrLabel new
		         text: 'Git URL: ';
		         aptitude: BrGlamorousLabelAptitude;
		         margin: (BlInsets right: 5).

	ownerEditor := BrEditableLabel new
		               aptitude:
			               BrGlamorousEditableLabelAptitude new
				               glamorousRegularFontAndSize;
		               text: ''.
	ownerEditor switchToEditor.
	ownerEditor hMatchParent.
	ownerEditor vExact: 23.
	label constraintsDo: [ :c | c grid vertical alignCenter ].
	ownerEditor constraintsDo: [ :c | c grid vertical alignCenter ].
	^ { 
		  label.
		  ownerEditor }
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> displayError: anError [

	errorElement
		text:
			'An authentication error occurred. Did you add a valid login method?
			
Please review "How to work with GitHub" in the Glamorous Toolkit Book for setup instructions.';
		aptitude: BrGlamorousRegularEditorAptitude new;
		vFitContent
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> dropdown: anObject [ 
	aDropdown := anObject
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> onCreated [

	^ onCreated ifNil: [ [ :repo |  ] ]
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> onCreated: aBlock [
	onCreated := aBlock
]

{ #category : #accessing }
GtGitGithubPageFormStencil >> projectLocation [
	|url owner project |
	url := ownerEditor text asString.
	url := url copyReplaceAll: 'git@github.com:' with: ''.
	url := url copyReplaceAll: '.git' with: ''.
	owner := (url findTokens: '/') first.
	project := (url findTokens: '/') last.
	^ IceLibgitRepository repositoriesLocation 
		/ owner
		/ project
]
