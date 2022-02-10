Class {
	#name : #GtGitDefinitionsListEditor,
	#superclass : #GtGitDefinitionsEditor,
	#instVars : [
		'elements',
		'completionStencil',
		'addSelector',
		'removeSelector'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsListEditor >> addSelector: aSelector [
	addSelector := aSelector
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> completionStencil: aStencil [
	completionStencil := aStencil
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> create [
	| aDefinition anOwner theInitialNames addAction removeAction renameAction aTagger |

	
	theInitialNames := self getValue.

	addAction := [ :aNewTag |
		aNewTag name
			ifNotEmpty: [ repository perform: addSelector withArguments: { aNewTag name } ] ].

	removeAction := [ :aTag | repository perform: removeSelector withArguments: { aTag name } ].

	aTagger := BrTagger new
		aptitude: (BrGlamorousTaggerEditableAptitude new
			margin: self margin;
			tagLabel: [ :aTaggerTag |
				| anEditableLabel eachLabelDefinition |


				anEditableLabel := BrEditableLabel new
					text: aTaggerTag name;
					aptitude: lookStencil create;
					yourself.
				
				completionStencil ifNotNil: [ :aStencil |
					(GtCompletionController
						on: anEditableLabel
						strategy: aStencil create) install ].
				
				anEditableLabel ];
			yourself);
		namedTags: theInitialNames;
		when: BrTaggerAddTagRequest do: [ :aRequest | addAction value: aRequest tag ];
		when: BrTaggerRemoveTagRequest do: [ :aRequest | removeAction value: aRequest tag ];
		when: BrTaggerRenameTagRequest do: [ :aRequest | renameAction value: aRequest tag value: aRequest newName ].
		
	^ aTagger
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> elements: aCollection [
	elements := aCollection
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> removeSelector: aSelector [
	removeSelector := aSelector
]
