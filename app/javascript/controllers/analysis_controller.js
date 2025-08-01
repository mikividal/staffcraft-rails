import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log(" Stimulus: connect() started")

    this.availableSkills = window.commonSkills || []
    this.availableTools = window.popularTools || []
    this.availableIntegrations = window.commonIntegrations || []
    this.toolsData = []  // Array para guardar datos de tools
    console.log("Loaded skills:", this.availableSkills.length)

    this.currentStep = 1
    this.totalSteps = 5

    this.initializeValidation()
    this.initializeConditionalFields()
    this.initializeAutoSave()

    // Limpia cualquier sesión anterior pero mantiene autoguardado para esta sesión
    localStorage.removeItem('staffcraft_draft')

    // Reset visual del formulario
    const industrySelect = document.querySelector('select[name*="industry_business_model"]')
    if (industrySelect) {
      industrySelect.selectedIndex = 0  // Selecciona el primer option (placeholder)

      // También oculta cualquier campo "other" que esté visible
      const otherGroup = document.getElementById('industry_other_group')
      if (otherGroup) {
        otherGroup.style.display = 'none'
        otherGroup.classList.remove('show')
      }
    }

    this.bindStepClicks()
    this.bindKeyboardNavigation()
    this.bindFormSubmit()
    this.injectShakeCSS()

    console.log("✅ Stimulus: analysis controller connected")
  }

  showSection(event) {
    const sectionNumber = parseInt(event.target.dataset.sectionNumberValue)

    if (sectionNumber > this.currentStep && !this.validateSection(this.currentStep)) {
      return
    }

    // Hide all sections
    document.querySelectorAll('.form-section').forEach(section => {
      section.classList.add('d-none')
    })

    // Show target section with animation
    const targetSection = document.getElementById(`section-${sectionNumber}`)
    if (targetSection) {
      setTimeout(() => {
        targetSection.classList.remove('d-none')
      }, 100)
    }

    this.currentStep = sectionNumber
    this.updateStepIndicators()
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  updateStepIndicators() {
    document.querySelectorAll('.step').forEach((step, index) => {
      const stepNumber = index + 1
      step.classList.remove('active', 'completed')

      if (stepNumber === this.currentStep) {
        step.classList.add('active')
      } else if (stepNumber < this.currentStep) {
        step.classList.add('completed')
      }
    })
  }

  toggleOtherField(event) {
    const inputElement = event.target
    const targetId = inputElement.dataset.toggleTarget
    const targetGroup = document.getElementById(targetId)

    if (!targetGroup) return

    // Para checkboxes
    if (inputElement.type === 'checkbox') {
      if (inputElement.checked) {
        targetGroup.style.display = 'block'
        targetGroup.classList.add('show')
      } else {
        targetGroup.classList.remove('show')
        setTimeout(() => {
          targetGroup.style.display = 'none'
          targetGroup.querySelectorAll('select').forEach(select => select.selectedIndex = 0)
          targetGroup.querySelectorAll('input').forEach(input => input.value = '')
        }, 300)
      }
    }
    // Para location_type - mostrar SOLO si es "remote_timezone"
    else if (inputElement.name && inputElement.name.includes('location_type')) {
      if (inputElement.value === 'remote_timezone') {
        targetGroup.style.display = 'block'
        targetGroup.classList.add('show')
      } else {
        targetGroup.classList.remove('show')
        setTimeout(() => {
          targetGroup.style.display = 'none'
          targetGroup.querySelectorAll('input').forEach(input => input.value = '')
        }, 300)
      }
    }
    // Para selects con "other"
    else {
      if (inputElement.value.includes('other')) {
        targetGroup.style.display = 'block'
        targetGroup.classList.add('show')
      } else {
        targetGroup.classList.remove('show')
        setTimeout(() => {
          targetGroup.style.display = 'none'
          targetGroup.querySelectorAll('input').forEach(input => input.value = '')
        }, 300)
      }
    }
  }

  // Para el tag list de skills

  addSkillFromInput() {
    const input = document.getElementById('skills-input')
    const skill = input.value.trim()

    if (skill) {
      this.createSkillTag(skill)
      input.value = ''
      this.updateHiddenSkillsField()
    }
  }

  createSkillTag(skill) {
    const tagsContainer = document.getElementById('skills-tags')
    const tag = document.createElement('span')
    tag.className = 'badge bg-primary me-2 mb-2 fs-6 skill-tag'
    tag.style.cursor = 'pointer'
    tag.innerHTML = `${skill} <i class="fas fa-times ms-1"></i>`

    tag.addEventListener('click', () => {
      tag.remove()
      this.updateHiddenSkillsField()
    })

    tagsContainer.appendChild(tag)
  }

  updateHiddenSkillsField() {
    const tags = document.querySelectorAll('.skill-tag')
    const hiddenField = document.getElementById('must_have_skills_hidden')

    if (!hiddenField) return  // ← Añade esta verificación

    const skills = Array.from(tags).map(tag => tag.textContent.replace(' ×', '').trim())
    hiddenField.value = skills.join(', ')
  }


  validateSection(sectionNumber) {
    const section = document.getElementById(`section-${sectionNumber}`)
    const requiredFields = section.querySelectorAll('[required]')
    let isValid = true

    requiredFields.forEach(field => {
      if (!field.value.trim()) {
        this.showFieldError(field, 'This field is required')
        field.classList.add('is-invalid')
        field.classList.remove('is-valid')
        isValid = false
      } else {
        this.hideFieldError(field)
        field.classList.remove('is-invalid')
        field.classList.add('is-valid')
      }
    })

    const urlFields = section.querySelectorAll('input[type="url"]')
    urlFields.forEach(field => {
      if (field.value && !this.isValidURL(field.value)) {
        this.showFieldError(field, 'Please enter a valid URL')
        field.classList.add('is-invalid')
        field.classList.remove('is-valid')
        isValid = false
      }
    })

    if (!isValid) {
      section.style.animation = 'shake 0.5s ease-in-out'
      setTimeout(() => {
        section.style.animation = ''
      }, 500)
    }

    return isValid
  }

  showFieldError(field, message) {
    this.hideFieldError(field)
    const errorDiv = document.createElement('div')
    errorDiv.className = 'field-error text-danger small mt-1'
    errorDiv.textContent = message
    field.parentElement.appendChild(errorDiv)
  }

  hideFieldError(field) {
    const errorDiv = field.parentElement.querySelector('.field-error')
    if (errorDiv) errorDiv.remove()
  }

  isValidURL(string) {
    try {
      new URL(string)
      return true
    } catch (_) {
      return false
    }
  }

  initializeValidation() {
    document.querySelectorAll('input, select, textarea').forEach(field => {
      field.addEventListener('blur', () => {
        if (field.hasAttribute('required') && !field.value.trim()) {
          this.showFieldError(field, 'This field is required')
          field.classList.add('is-invalid')
          field.classList.remove('is-valid')
        } else if (field.value.trim()) {
          this.hideFieldError(field)
          field.classList.remove('is-invalid')
          field.classList.add('is-valid')
        }

        if (field.type === 'url' && field.value && !this.isValidURL(field.value)) {
          this.showFieldError(field, 'Please enter a valid URL')
          field.classList.add('is-invalid')
          field.classList.remove('is-valid')
        }
      })

      field.addEventListener('input', () => {
        if (field.classList.contains('is-invalid') && field.value.trim()) {
          this.hideFieldError(field)
          field.classList.remove('is-invalid')
          field.classList.add('is-valid')
        }
      })
    })
  }

  initializeConditionalFields() {
    // already handled inline via onchange
  }

  initializeAutoSave() {
    let autoSaveTimeout

    document.querySelectorAll('input, select, textarea').forEach(field => {
      field.addEventListener('input', () => {
        clearTimeout(autoSaveTimeout)
        autoSaveTimeout = setTimeout(() => {
          this.saveFormData()
        }, 2000)
      })
    })
  }

  saveFormData() {
    try {
      const formData = new FormData(document.getElementById('staffcraft-form'))
      const dataObject = {}

      for (let [key, value] of formData.entries()) {
        dataObject[key] = value
      }

      localStorage.setItem('staffcraft_draft', JSON.stringify(dataObject))
      this.showSaveIndicator()
    } catch (e) {
      console.log('Could not save form data')
    }
  }

  showSaveIndicator() {
    const existing = document.querySelector('.save-indicator')
    if (existing) existing.remove()

    const indicator = document.createElement('div')
    indicator.className = 'save-indicator position-fixed top-0 end-0 m-3 alert alert-success alert-dismissible fade show'
    indicator.style.zIndex = '9999'
    indicator.innerHTML = `
      <svg class="checkmark me-2" viewBox="0 0 24 24" width="20" height="20" stroke="currentColor" fill="none">
        <path d="M20 6L9 17l-5-5"/>
      </svg>
      Draft saved automatically
    `

    document.body.appendChild(indicator)

    setTimeout(() => {
      if (indicator.parentNode) {
        indicator.remove()
      }
    }, 3000)
  }

  loadSavedData() {
    try {
      const savedData = localStorage.getItem('staffcraft_draft')
      if (savedData) {
        const data = JSON.parse(savedData)
        Object.keys(data).forEach(key => {
          const field = document.querySelector(`[name="${key}"]`)
          if (field && !field.value) {
            field.value = data[key]
          }
        })
      }
    } catch (e) {
      console.log('Could not load saved data')
    }
  }

  bindStepClicks() {
    document.querySelectorAll('.step').forEach((step, index) => {
      step.addEventListener('click', () => {
        const stepNumber = index + 1
        if (stepNumber <= this.currentStep || this.validateAllPreviousSections(stepNumber)) {
          this.showSection(stepNumber)
        }
      })
    })
  }

  validateAllPreviousSections(targetStep) {
    for (let i = 1; i < targetStep; i++) {
      if (!this.validateSection(i)) {
        return false
      }
    }
    return true
  }

  bindKeyboardNavigation() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' && this.currentStep < this.totalSteps) {
        if (this.validateSection(this.currentStep)) {
          this.showSection(this.currentStep + 1)
        }
      } else if (e.key === 'ArrowLeft' && this.currentStep > 1) {
        this.showSection(this.currentStep - 1)
      }
    })
  }

  bindFormSubmit() {
    const form = document.getElementById('staffcraft-form')
    if (!form) return

    form.addEventListener('submit', (e) => {
      let allValid = true
      for (let i = 1; i <= this.totalSteps; i++) {
        if (!this.validateSection(i)) {
          allValid = false
          this.showSection(i)
          break
        }
      }

      if (!allValid) {
        e.preventDefault()
        return
      }

      const submitButton = document.getElementById('submit-button')
      if (submitButton) {
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing Analysis...'
        submitButton.classList.add('loading')
      }

      localStorage.removeItem('staffcraft_draft')
    })
  }

  injectShakeCSS() {
    const style = document.createElement('style')
    style.textContent = `
      @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
      }
    `
    document.head.appendChild(style)
  }

  // Filtrar y mostrar sugerencias
  filterSkills(event) {
    const input = event.target
    const query = input.value.toLowerCase().trim()
    const suggestionsDiv = document.getElementById('skills-suggestions')

    if (!suggestionsDiv) return  // ← Añade esta verificación

    if (query.length < 2) {
      suggestionsDiv.style.display = 'none'
      return
    }

    const filteredSkills = this.availableSkills.filter(skill =>
      skill.toLowerCase().includes(query) &&
      !this.isSkillAlreadyAdded(skill)
    ).slice(0, 8)

    this.displaySuggestions(filteredSkills)
  }

// Mostrar dropdown de sugerencias
  showSuggestions() {
    const suggestionsDiv = document.getElementById('skills-suggestions')
    if (!suggestionsDiv) return  // ← Añade esta verificación

    if (this.availableSkills.length > 0) {
      const topSkills = this.availableSkills.filter(skill =>
        !this.isSkillAlreadyAdded(skill)
      ).slice(0, 8)
      this.displaySuggestions(topSkills)
    }
  }

  // Renderizar las sugerencias
  displaySuggestions(skills) {
    const suggestionsDiv = document.getElementById('skills-suggestions')
    if (!suggestionsDiv) return  // ← Añade esta verificación

    if (skills.length === 0) {
      suggestionsDiv.style.display = 'none'
      return
    }

    suggestionsDiv.innerHTML = skills.map(skill =>
      `<div class="suggestion-item p-2 border-bottom" style="cursor: pointer;" data-skill="${skill}">
        ${skill}
      </div>`
    ).join('')

    // Añadir event listeners
    suggestionsDiv.querySelectorAll('.suggestion-item').forEach(item => {
      item.addEventListener('click', () => {
        this.addSkillFromSuggestion(item.dataset.skill)
      })
    })

    suggestionsDiv.style.display = 'block'
  }

  // Añadir skill desde sugerencia
  addSkillFromSuggestion(skill) {
    this.createSkillTag(skill)
    document.getElementById('skills-input').value = ''
    document.getElementById('skills-suggestions').style.display = 'none'
    this.updateHiddenSkillsField()
  }

  // Verificar si skill ya está añadida
  isSkillAlreadyAdded(skill) {
    const existingTags = document.querySelectorAll('.skill-tag')
    return Array.from(existingTags).some(tag =>
      tag.textContent.replace(' ×', '').trim().toLowerCase() === skill.toLowerCase()
    )
  }

  // Actualizar el método addSkill para ocultar sugerencias
   addSkill(event) {
    // Solo manejar Enter y Escape, no otras teclas
    if (event.key === 'Enter') {
      event.preventDefault()
      this.addSkillFromInput()

      // Verificar que el elemento existe antes de acceder a .style
      const suggestionsDiv = document.getElementById('skills-suggestions')
      if (suggestionsDiv) {
        suggestionsDiv.style.display = 'none'
      }
    } else if (event.key === 'Escape') {
      const suggestionsDiv = document.getElementById('skills-suggestions')
      if (suggestionsDiv) {
        suggestionsDiv.style.display = 'none'
      }
    }
  }


  // Métodos para Tools (similares a skills pero con cards)
  addToolKeydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this.addToolFromInput()
    } else if (event.key === 'Escape') {
      const suggestionsDiv = document.getElementById('tools-suggestions')
      if (suggestionsDiv) suggestionsDiv.style.display = 'none'
    }
  }

  addToolFromInput() {
    const input = document.getElementById('tools-input')
    if (!input) return

    const tool = input.value.trim()
    if (tool && !this.isToolAlreadyAdded(tool)) {
      this.createToolCard(tool)
      input.value = ''
      const suggestionsDiv = document.getElementById('tools-suggestions')
      if (suggestionsDiv) suggestionsDiv.style.display = 'none'
      this.updateToolsData()
    }
  }

  createToolCard(toolName) {
    const container = document.getElementById('tools-container')
    if (!container) return

    const toolId = `tool-${Date.now()}` // ID único

    const card = document.createElement('div')
    card.className = 'tool-card border rounded p-3 mb-3'
    card.id = toolId
    card.innerHTML = `
      <div class="d-flex justify-content-between align-items-center mb-2">
        <h6 class="mb-0">🛠️ ${toolName}</h6>
        <button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('.tool-card').remove(); window.analysisController.updateToolsData()">
          <i class="fas fa-times"></i>
        </button>
      </div>

      <div class="row g-2">
        <div class="col-md-6">
          <input type="text"
                class="form-control subscription-input"
                placeholder="Subscription type (e.g., Pro Plan, Free)"
                data-tool="${toolName}">
        </div>
        <div class="col-md-6">
          <div class="position-relative">
            <input type="text"
                  class="form-control integrations-input"
                  placeholder="Live integrations"
                  data-tool="${toolName}"
                  data-action="input->analysis#filterIntegrations focus->analysis#showIntegrationSuggestions">
            <div class="integrations-suggestions position-absolute w-100 bg-white border rounded shadow-sm"
                style="display: none; top: 100%; z-index: 1001; max-height: 150px; overflow-y: auto;">
            </div>
          </div>
        </div>
      </div>
    `

    container.appendChild(card)

    // Hacer disponible globally para el onclick
    window.analysisController = this
  }

  filterTools(event) {
    const input = event.target
    const query = input.value.toLowerCase().trim()
    const suggestionsDiv = document.getElementById('tools-suggestions')

    if (!suggestionsDiv) return

    if (query.length < 2) {
      suggestionsDiv.style.display = 'none'
      return
    }

    const filteredTools = this.availableTools.filter(tool =>
      tool.toLowerCase().includes(query) &&
      !this.isToolAlreadyAdded(tool)
    ).slice(0, 8)

    this.displayToolSuggestions(filteredTools)
  }

  showToolSuggestions() {
    const suggestionsDiv = document.getElementById('tools-suggestions')
    if (!suggestionsDiv) return

    if (this.availableTools.length > 0) {
      const topTools = this.availableTools.filter(tool =>
        !this.isToolAlreadyAdded(tool)
      ).slice(0, 8)
      this.displayToolSuggestions(topTools)
    }
  }

  displayToolSuggestions(tools) {
    const suggestionsDiv = document.getElementById('tools-suggestions')
    if (!suggestionsDiv) return

    if (tools.length === 0) {
      suggestionsDiv.style.display = 'none'
      return
    }

    suggestionsDiv.innerHTML = tools.map(tool =>
      `<div class="suggestion-item p-2 border-bottom" style="cursor: pointer;" data-tool="${tool}">
        ${tool}
      </div>`
    ).join('')

    suggestionsDiv.querySelectorAll('.suggestion-item').forEach(item => {
      item.addEventListener('click', () => {
        this.addToolFromSuggestion(item.dataset.tool)
      })
    })

    suggestionsDiv.style.display = 'block'
  }

  addToolFromSuggestion(tool) {
    this.createToolCard(tool)
    document.getElementById('tools-input').value = ''
    document.getElementById('tools-suggestions').style.display = 'none'
    this.updateToolsData()
  }

  isToolAlreadyAdded(tool) {
    const existingCards = document.querySelectorAll('.tool-card h6')
    return Array.from(existingCards).some(card =>
      card.textContent.replace('🛠️ ', '').trim().toLowerCase() === tool.toLowerCase()
    )
  }

  updateToolsData() {
    const cards = document.querySelectorAll('.tool-card')
    const toolsData = []

    cards.forEach(card => {
      const toolName = card.querySelector('h6').textContent.replace('🛠️ ', '').trim()
      const subscription = card.querySelector('.subscription-input').value
      const integrations = card.querySelector('.integrations-input').value

      toolsData.push({
        tool: toolName,
        subscription: subscription,
        integrations: integrations
      })
    })

    this.toolsData = toolsData
    const hiddenField = document.getElementById('tools_data_hidden')
    if (hiddenField) {
      hiddenField.value = JSON.stringify(toolsData)
    }
  }
}
