"
This is a stragegy that augments {{gtClass:IceCheckoutAlreadyLoadedPackages}} with support for updating Lepiter databases already loaded inside the image. 

If a database is removed from disk it will also be removed from the in-image working copy.
"
Class {
	#name : #GtIceCheckoutAlreadyLoadedContent,
	#superclass : #IceCheckoutAlreadyLoadedPackages,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtIceCheckoutAlreadyLoadedContent class >> description [
	^ 'Checkout packages and Lepiter databases ALREADY LOADED in the image'
]

{ #category : #accessing }
GtIceCheckoutAlreadyLoadedContent class >> gtDescription [
	^ 'Checkout packages and Lepiter databases already loaded in the image'
]

{ #category : #accessing }
GtIceCheckoutAlreadyLoadedContent class >> isGtStrategy [
	^ true
]

{ #category : #accessing }
GtIceCheckoutAlreadyLoadedContent class >> order [
	^ 9
]

{ #category : #checkout }
GtIceCheckoutAlreadyLoadedContent >> checkoutOn: anIceWorkingCopy [ 
	"Calling super performs a forced checkout. After this updates files from disk, trigger a reload of lepiter databases affected by this change."
	
	super checkoutOn: anIceWorkingCopy.
	lepiterWorkingCopy ifNil: [ ^ self ].
	lepiterWorkingCopy loadLepiterChangesInWorkingCopyFrom: self diff.
]

{ #category : #accessing }
GtIceCheckoutAlreadyLoadedContent >> diff [
	
	^ diff ifNil: [ 
		diff := committish diffTo: lepiterWorkingCopy ].
]

{ #category : #accessing }
GtIceCheckoutAlreadyLoadedContent >> lepiterWorkingCopy [

	^ lepiterWorkingCopy
]

{ #category : #accessing }
GtIceCheckoutAlreadyLoadedContent >> lepiterWorkingCopy: aLepiterWorkingCopy [

	lepiterWorkingCopy := aLepiterWorkingCopy
]
