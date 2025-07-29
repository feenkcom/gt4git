Class {
	#name : #GtLepiterPagesDefinition,
	#superclass : #GtLepiterDefinition,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterPagesDefinition >> icon [
	^ self iconNamed: #emptyPackage
]

{ #category : #accessing }
GtLepiterPagesDefinition >> iconName [
	"Used in Pharo 12 instead of #icon"
	^ #emptyPackage
]

{ #category : #initialization }
GtLepiterPagesDefinition >> initialize [
	super initialize.
	self name: 'pages'.
]
