Class {
	#name : #GtGitGithubPageForm,
	#superclass : #Object,
	#instVars : [
		'dropdown',
		'onCreated',
		'url'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
GtGitGithubPageForm >> asElement [
	^ (self asGtMagritteViewModel
		onElementCreated: [ :aFrame | 
			BlFocusFinder new
				direction: BlFocusSearchDirectionForward new;
				root: aFrame;
				referenceElement: nil;
				nextFocusDo: #requestFocus ifNone: [  ] ]) asElement
		padding: ((BlInsets all: 10) withRight: 5)
]

{ #category : #accessing }
GtGitGithubPageForm >> dropdown [
	^ dropdown
]

{ #category : #accessing }
GtGitGithubPageForm >> dropdown: anObject [
	dropdown := anObject
]

{ #category : #accessing }
GtGitGithubPageForm >> initialize [
	url := 'https://example.com'
]

{ #category : #accessing }
GtGitGithubPageForm >> magritteAcceptAction [
	<magritteActionDescription>
	super magritteAcceptAction
		onSuccessCallback: (GtMagritteActionExecutor new
			beInUIProcess;
			action: [ :aModel :aButton :aMemento :aDescription | 
				[ | creator repo |
				creator := IceRepositoryCreator new
						remote: (IceGitRemote url: self url);
						location: self projectLocation.
				repo := creator createRepository.
				repo register.
				dropdown ifNotNil: [ 
					dropdown dispatchEvent: (
						BrDropdownHideWish new anchor: dropdown) ].
				self onCreated value: repo ] on: Error do: #debug ]);
		beEnabledOnValidOverallStatus.
]

{ #category : #accessing }
GtGitGithubPageForm >> onCreated [
	^ onCreated
]

{ #category : #accessing }
GtGitGithubPageForm >> onCreated: anObject [
	onCreated := anObject
]

{ #category : #accessing }
GtGitGithubPageForm >> projectLocation [
	| anUrl owner project |
	anUrl := url copyReplaceAll: 'git@github.com:' with: ''.
	anUrl := anUrl copyReplaceAll: '.git' with: ''.
	owner := (anUrl findTokens: '/') first.
	project := (anUrl findTokens: '/') last.
	^ IceLibgitRepository repositoriesLocation / owner / project
]

{ #category : #accessing }
GtGitGithubPageForm >> url [
	^ url
]

{ #category : #accessing }
GtGitGithubPageForm >> url: anObject [
	url := anObject
]

{ #category : #accessing }
GtGitGithubPageForm >> urlDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'URL';
		priority: 1;
		accessor: #url;
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousCodeFontAndSmallSize ]
]
